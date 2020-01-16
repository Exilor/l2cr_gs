require "./abstract_olympiad_game"
require "./game_state"

class OlympiadGameTask
  include Loggable
  include Synchronizable

  private alias SystemMessage = Packets::Outgoing::SystemMessage

  private TELEPORT_TO_ARENA_TIMES = {
    120,
    60,
    30,
    15,
    10,
    5,
    4,
    3,
    2,
    1,
    0
  }
  private BATTLE_START_TIME_FIRST = {
    60,
    50,
    40,
    30,
    20,
    10,
    0
  }
  private BATTLE_START_TIME_SECOND = {
    10,
    5,
    4,
    3,
    2,
    1,
    0
  }
  private TELEPORT_TO_TOWN_TIMES = {
    40,
    30,
    20,
    10,
    5,
    4,
    3,
    2,
    1,
    0
  }

  @state = GameState::IDLE
  @needs_announce = false
  @countdown = 0
  getter! game : AbstractOlympiadGame?
  getter zone


  def initialize(zone : L2OlympiadStadiumZone)
    @zone = zone
    zone.register_task(self)
  end

  def battle_period : Int64
    Config.alt_oly_battle # 6 mins
  end

  def running? : Bool
    !@state.idle?
  end

  def game_started? : Bool
    @state.between?(GameState::GAME_STARTED, GameState::CLEANUP)
  end

  def battle_started? : Bool
    @state.battle_in_progress?
  end

  def battle_finished? : Bool
    @state.teleport_to_town?
  end

  def needs_announce? : Bool
    if @needs_announce
      @needs_announce = false
      return true
    end

    false
  end

  def attach_game(game : AbstractOlympiadGame?)
    if game && !@state.idle?
      warn { "Attempted to overwrite non-finished game in state #{@state}." }
      return
    end

    @game = game
    @state = GameState::START
    @needs_announce = false
    ThreadPoolManager.execute_general(self)
  end

  def call
    delay = 1 # schedule next call after 1s
    case @state
    # Game created
    when GameState::START
      @state = GameState::TELEPORT_TO_ARENA
      @countdown = Config.alt_oly_wait_time
    # Teleport to arena countdown
    when GameState::TELEPORT_TO_ARENA
      if @countdown > 0
        sm = SystemMessage.you_will_enter_the_olympiad_stadium_in_s1_second_s
        sm.add_int(@countdown)
        @game.not_nil!.broadcast_packet(sm)
      end

      delay = get_delay(TELEPORT_TO_ARENA_TIMES)
      if @countdown <= 0
        @state = GameState::GAME_STARTED
      end
    # Game start, port players to arena
    when GameState::GAME_STARTED
      if start_game
        @state = GameState::BATTLE_COUNTDOWN_FIRST
        @countdown = BATTLE_START_TIME_FIRST[0]
        delay = 5
      else
        @state = GameState::GAME_CANCELLED
      end
    # Battle start countdown, first part (60-10)
    when GameState::BATTLE_COUNTDOWN_FIRST
      if @countdown > 0
        sm = SystemMessage.the_game_will_start_in_s1_second_s
        sm.add_int(@countdown)
        @zone.broadcast_packet(sm)
      end

      delay = get_delay(BATTLE_START_TIME_FIRST)
      if @countdown <= 0
        open_doors

        @state = GameState::BATTLE_COUNTDOWN_SECOND
        @countdown = BATTLE_START_TIME_SECOND[0]
        delay = get_delay(BATTLE_START_TIME_SECOND)
      end
    # Battle start countdown, second part (10-0)
    when GameState::BATTLE_COUNTDOWN_SECOND
      if @countdown > 0
        sm = SystemMessage.the_game_will_start_in_s1_second_s
        sm.add_int(@countdown)
        @zone.broadcast_packet(sm)
      end

      delay = get_delay(BATTLE_START_TIME_SECOND)
      if @countdown <= 0
        @state = GameState::BATTLE_STARTED
      end
    # Beginning of the battle
    when GameState::BATTLE_STARTED
      @countdown = 0
      @state = GameState::BATTLE_IN_PROGRESS # set state first, used in zone update
      unless start_battle
        @state = GameState::GAME_STOPPED
      end
    # Checks during battle
    when GameState::BATTLE_IN_PROGRESS
      @countdown += 1000
      if check_battle || @countdown > Config.alt_oly_battle
        @state = GameState::GAME_STOPPED
      end
    # Battle cancelled before teleport participants to the stadium
    when GameState::GAME_CANCELLED
      stop_game
      @state = GameState::CLEANUP
    # End of the battle
    when GameState::GAME_STOPPED
      @state = GameState::TELEPORT_TO_TOWN
      @countdown = TELEPORT_TO_TOWN_TIMES[0]
      stop_game
      delay = get_delay(TELEPORT_TO_TOWN_TIMES)
    # Teleport to town countdown
    when GameState::TELEPORT_TO_TOWN
      if @countdown > 0
        sm = SystemMessage.you_will_be_moved_to_town_in_s1_seconds
        sm.add_int(@countdown)
        @game.not_nil!.broadcast_packet(sm)
      end

      delay = get_delay(TELEPORT_TO_TOWN_TIMES)
      if @countdown <= 0
        @state = GameState::CLEANUP
      end
    # Removals
    when GameState::CLEANUP
      clean_up_game
      @state = GameState::IDLE
      @game = nil
      return
    end

    ThreadPoolManager.schedule_general(self, delay * 1000)
  rescue e
    case @state
    when GameState::GAME_STOPPED, GameState::TELEPORT_TO_TOWN, GameState::CLEANUP,
         GameState::IDLE
      warn e
      warn { "Unable to return players back in town." }
      @state = GameState::IDLE
      @game = nil
      return
    end

    warn e
    warn { "Exception in #{@state}, trying to port players back." }
    @state = GameState::GAME_STOPPED
    ThreadPoolManager.schedule_general(self, 1000)
  end

  private def get_delay(times : Enumerable(Int32)) : Int32
    times.each do |time|
      if time >= @countdown
        next
      end

      delay = @countdown - time
      @countdown = time
      return delay
    end
    # should not happens
    @countdown = -1

    1
  end

  private def start_game
    # Checking for opponents and teleporting to arena
    if @game.not_nil!.check_defaulted
      return false
    end

    @zone.close_doors
    if @game.not_nil!.needs_buffers?
      @zone.spawn_buffers
    end

    unless @game.not_nil!.port_players_to_arena(@zone.spawns.not_nil!)
      return false
    end

    @game.not_nil!.removals
    @needs_announce = true
    OlympiadGameManager.start_battle # inform manager
    true
  rescue e
    error e
    false
  end

  private def open_doors
    @game.not_nil!.reset_damage
    @zone.open_doors
  rescue e
    error e
  end

  private def start_battle
    begin
      if @game.not_nil!.needs_buffers?
        @zone.delete_buffers
      end

      if @game.not_nil!.check_battle_status && @game.not_nil!.make_competition_start
        # game successfully started
        @game.not_nil!.broadcast_olympiad_info(@zone)
        @zone.broadcast_packet(SystemMessage.starts_the_game)
        @zone.update_zone_status_for_characters_inside
        return true
      end
    rescue e
      error e
    end

    false
  end

  private def check_battle : Bool
    begin
      return @game.not_nil!.has_winner?
    rescue e
      error e
    end

    true
  end

  private def stop_game
    begin
      @game.not_nil!.validate_winner(@zone)
    rescue e
      error e
    end

    begin
      @zone.update_zone_status_for_characters_inside
    rescue e
      error e
    end

    begin
      @game.not_nil!.clean_effects
    rescue e
      error e
    end
  end

  private def clean_up_game
    begin
      @game.not_nil!.players_status_back
    rescue e
      error e
    end

    begin
      @game.not_nil!.port_players_back
    rescue e
      error e
    end

    begin
      @game.not_nil!.clear_players
    rescue e
      error e
    end

    begin
      @zone.close_doors
    rescue e
      error e
    end
  end
end
