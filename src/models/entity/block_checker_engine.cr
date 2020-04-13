class BlockCheckerEngine
  include Loggable
  include Synchronizable
  include Packets::Outgoing

  # Arena X: team1X, team1Y, team2X, team2Y, ArenaCenterX, ArenaCenterY
  private ARENA_COORDINATES = {
    {
    # Arena 0 - Team 1 XY, Team 2 XY - CENTER XY
      -58368,
      -62745,
      -57751,
      -62131,
      -58053,
      -62417
    },
    {
    # Arena 1 - Team 1 XY, Team 2 XY - CENTER XY
      -58350,
      -63853,
      -57756,
      -63266,
      -58053,
      -63551
    },
    {
    # Arena 2 - Team 1 XY, Team 2 XY - CENTER XY
      -57194,
      -63861,
      -56580,
      -63249,
      -56886,
      -63551
    },
    {
    # Arena 3 - Team 1 XY, Team 2 XY - CENTER XY
      -57200,
      -62727,
      -56584,
      -62115,
      -56850,
      -62391
    }
  }

  private DEFAULT_ARENA = -1i8

  # Maps to hold player of each team and his points
  getter red_team_points = Concurrent::Map(L2PcInstance, Int32).new
  getter blue_team_points = Concurrent::Map(L2PcInstance, Int32).new
  # The initial points of the event
  property red_points = 15
  property blue_points = 15
  # Sets if the red team won the event at the end of this (used for packets)
  @red_winner = false
  # All blocks
  getter spawns = Concurrent::Array(L2Spawn).new
  # Common z coordinate
  getter z_coord = -2405
  # List of dropped items in event (for later deletion)
  @drops = Concurrent::Array(L2ItemInstance).new

  # Current used arena
  getter arena = -1
  # The object which holds all basic members info
  getter! holder : ArenaParticipantsHolder
  # Time when the event starts. Used on packet sending
  property started_time = 0i64
  # Event is started
  property? started = false
  # Event end
  setter task : TaskExecutor::Scheduler::DelayedTask?
  # Preserve from exploit reward by logging out
  @abnormal_end = false

  def initialize(holder : ArenaParticipantsHolder, arena : Int32)
    @holder = holder
    if arena > -1 && arena < 4
      @arena = arena
    end

    holder.red_players.each do |pc|
      @red_team_points[pc] = 0
    end
    holder.blue_players.each do |pc|
      @blue_team_points[pc] = 0
    end
  end

  # * Updates the player holder before the event starts to synchronize all info
  # * @param holder
  def update_players_on_start(holder : ArenaParticipantsHolder)
    @holder = holder
  end

  # * Returns the current red team points
  # * @return int
  def red_points : Int32
    sync { @red_points }
  end

  # * Returns the current blue team points
  # * @return int
  def blue_points : Int32
    sync { @blue_points }
  end

  # * Returns the player points
  # * @param player
  # * @param red
  # * @return int
  def get_player_points(pc : L2PcInstance, red : Bool)
    red ? @red_team_points[pc]? || 0 : @blue_team_points[pc]? || 0
  end

  # * Increases player points for his teams
  # * @param player
  # * @param team
  def increase_player_points(pc : L2PcInstance, team : Int32)
    sync do
      return unless pc

      if team == 0
        points = @red_team_points[pc] + 1
        @red_team_points[pc] = points
        @red_points += 1
        @blue_points -= 1
      else
        points = @blue_team_points[pc] + 1
        @blue_team_points[pc] = points
        @blue_points += 1
        @red_points -= 1
      end
    end
  end

  # * Will add a new drop into the list of dropped items
  # * @param item
  def add_new_drop(item : L2ItemInstance)
    if item
      @drops << item
    end
  end

  # * Will send all packets for the event members with the relation info
  # * @param plr
  def broadcast_relation_changed(pc : L2PcInstance)
    @holder.not_nil!.all_players.each do |p|
      rc = RelationChanged.new(pc, pc.get_relation(p), pc.auto_attackable?(p))
      p.send_packet(rc)
    end
  end

  # * Called when a there is an empty team. The event will end.
  def end_event_abnormally
    sync do
      @started = false
      @task.try &.cancel
      @abnormal_end = true

      ThreadPoolManager.execute_general(->end_event_task)

      debug { "Event at arena #{@arena} ended due lack of participants." }
    end
  rescue e
    error e
  end

  # * This inner class set ups all player and arena parameters to start the event
  class StartEvent
    include Loggable

    def initialize(engine : BlockCheckerEngine)
      @engine = engine
      # Initialize all used skills
      @freeze = SkillData[6034, 1]
      @transformation_red = SkillData[6035, 1]
      @transformation_blue = SkillData[6036, 1]
    end

     # * Will set up all player parameters and port them to their respective location based on their teams
    private def set_up_players
      # Set current arena as being used
      HandysBlockCheckerManager.arena_being_used = @engine.arena

      # Initialize packets avoiding create a new one per player
      @engine.red_points = @engine.spawns.size // 2
      @engine.blue_points = @engine.spawns.size // 2
      initial_points = ExCubeGameChangePoints.new(300, @engine.blue_points, @engine.red_points)

      @engine.holder.not_nil!.all_players.each do |pc|
        # Send the secret client packet set up
        red = @engine.holder.not_nil!.red_players.includes?(pc)

        client_set_up = ExCubeGameExtendedChangePoints.new(300, @engine.blue_points, @engine.red_points, red, pc, 0)
        pc.send_packet(client_set_up)

        pc.action_failed

        # Teleport Player - Array access
        # Team 0 * 2 = 0; 0 = 0, 0 + 1 = 1.
        # Team 1 * 2 = 2; 2 = 2, 2 + 1 = 3
        tc = @engine.holder.not_nil!.get_player_team(pc) * 2
        # Get x and y coordinates
        x = ARENA_COORDINATES[@engine.arena][tc]
        y = ARENA_COORDINATES[@engine.arena][tc + 1]
        pc.tele_to_location(x, y, @engine.z_coord)
        # Set the player team
        if red
          @engine.red_team_points[pc] = 0
          pc.team = Team::RED
        else
          @engine.blue_team_points[pc] = 0
          pc.team = Team::BLUE
        end
        pc.stop_all_effects

        pc.summon.try &.unsummon(pc)

        # Give the player start up effects
        # Freeze
        @freeze.apply_effects(pc, pc)
        # Transformation
        if @engine.holder.not_nil!.get_player_team(pc) == 0
          @transformation_red.apply_effects(pc, pc)
        else
          @transformation_blue.apply_effects(pc, pc)
        end
        # Set the current player arena
        pc.block_checker_arena = @engine.arena.to_i8
        pc.inside_pvp_zone = true
        # Send needed packets
        pc.send_packet(initial_points)
        pc.send_packet(ExCubeGameCloseUI::STATIC_PACKET)
        # ExBasicActionList
        pc.send_packet(ExBasicActionList::DEFAULT_LIST)
        @engine.broadcast_relation_changed(pc)
      end
    end

    def call
      # Wrong arena passed, stop event
      if @engine.arena == -1
        warn "Couldnt set up the arena id for the Block Checker event. Event cancelled."
        return
      end
      @engine.started = true
      # Spawn the blocks
      ThreadPoolManager.execute_general(SpawnRound.new(@engine, 16, 1))
      # Start up player parameters
      set_up_players
      # Set the started time
      @engine.started_time = Time.ms + 300000
    end
  end

  # * This class spawns the second round of boxes and schedules the event end
  private class SpawnRound
    include Loggable

    initializer engine : BlockCheckerEngine, num_of_boxes : Int32, round : Int32

    def call
      unless @engine.started?
        return
      end

      case @round
      when 1
        # Schedule second spawn round
        @engine.task = ThreadPoolManager.schedule_general(SpawnRound.new(@engine, 20, 2), 60000)
      when 2
        # Schedule third spawn round
        @engine.task = ThreadPoolManager.schedule_general(SpawnRound.new(@engine, 14, 3), 60000)
      when 3
        # Schedule Event End Count Down
        @engine.task = ThreadPoolManager.schedule_general(-> { @engine.end_event_task }, 180000)
      else
        # [automatically added else]
      end

      # random % 2, if == 0 will spawn a red block
      # if != 0, will spawn a blue block
      random = 2
      # Spawn blocks
      begin
        # Creates 50 new blocks
        @num_of_boxes.times do |i|
          sp = L2Spawn.new(18672)
          sp.x = ARENA_COORDINATES[@engine.arena][4] + Rnd.rand(-400..400)
          sp.y = ARENA_COORDINATES[@engine.arena][5] + Rnd.rand(-400..400)
          sp.z = @engine.z_coord
          sp.amount = 1
          sp.heading = 1
          sp.respawn_delay = 1
          SpawnTable.add_new_spawn(sp, false)
          sp.init
          block = sp.last_spawn.as(L2BlockInstance)
          # switch color
          if random % 2 == 0
            block.red = true
          else
            block.red = false
          end

          block.disable_core_ai(true)
          @engine.spawns << sp
          random += 1
        end
      rescue e
        error e
      end

      # Spawn the block carrying girl
      if @round == 1 || @round == 2
        begin
          girl_sp = L2Spawn.new(18676)
          girl_sp.x = ARENA_COORDINATES[@engine.arena][4] + Rnd.rand(-400..400)
          girl_sp.y = ARENA_COORDINATES[@engine.arena][5] + Rnd.rand(-400..400)
          girl_sp.z = @engine.z_coord
          girl_sp.amount = 1
          girl_sp.heading = 1
          girl_sp.respawn_delay = 1
          SpawnTable.add_new_spawn(girl_sp, false)
          girl_sp.init
          # Schedule his deletion after 9 secs of spawn
          ThreadPoolManager.schedule_general(CarryingGirlUnspawn.new(girl_sp), 9000)
        rescue e
          error e
        end
      end

      @engine.red_points += @num_of_boxes // 2
      @engine.blue_points += @num_of_boxes // 2

      time_left = ((@engine.started_time - Time.ms) / 1000).to_i
      change_points = ExCubeGameChangePoints.new(time_left, @engine.blue_points, @engine.red_points)
      @engine.holder.broadcast_packet_to_team(change_points)
    end
  end

  private struct CarryingGirlUnspawn
    initializer sp : L2Spawn

    def call
      SpawnTable.delete_spawn(@sp, false)
      @sp.stop_respawn
      @sp.last_spawn.not_nil!.delete_me
    end
  end

  # Garbage collector and arena free setter
  private def clear_me
    HandysBlockCheckerManager.clear_paticipant_queue_by_arena_id(@arena)
    @holder.not_nil!.clear_players
    @blue_team_points.clear
    @red_team_points.clear
    HandysBlockCheckerManager.set_arena_free(@arena)

    @spawns.each do |sp|
      sp.stop_respawn
      sp.last_spawn.not_nil!.delete_me
      SpawnTable.delete_spawn(sp, false)
    end
    @spawns.clear

    @drops.each do |item|
      # a player has it, it will be deleted later
      if !item.visible? || item.owner_id != 0
        next
      end

      item.decay_me
      L2World.remove_object(item)
    end
    @drops.clear
  end

   # * Reward players after event. Tie - No Reward
  private def reward_players
    if @red_points == @blue_points
      return
    end

    @red_winner = @red_points > @blue_points ? true : false

    if @red_winner
      reward_as_winner(true)
      reward_as_loser(false)
      sm = SystemMessage.team_c1_won
      sm.add_string("Red Team")
      @holder.not_nil!.broadcast_packet_to_team(sm)
    elsif @blue_points > @red_points
      reward_as_winner(false)
      reward_as_loser(true)
      sm = SystemMessage.team_c1_won
      sm.add_string("Blue Team")
      @holder.not_nil!.broadcast_packet_to_team(sm)
    else
      reward_as_loser(true)
      reward_as_loser(false)
    end
  end

   # * Reward the specified team as a winner team 1) Higher score - 8 extra 2) Higher score - 5 extra
   # * @param red
  private def reward_as_winner(red)
    temp_points = red ? @red_team_points : @blue_team_points

    # Main give
    temp_points.each do |key, value|
      if value >= 10
        key.add_item("Block Checker", 13067, 2, key, true)
      else
        temp_points.delete(key)
      end
    end

    first = 0
    second = 0
    winner1 = nil
    winner2 = nil
    temp_points.each do |key, value|
      pc = key
      pc_points = value
      if pc_points > first
        # Move old data
        second = first
        winner2 = winner1
        # Set new data
        first = pc_points
        winner1 = pc
      elsif pc_points > second
        second = pc_points
        winner2 = pc
      end
    end
    if winner1
      winner1.add_item("Block Checker", 13067, 8, winner1, true)
    end
    if winner2
      winner2.add_item("Block Checker", 13067, 5, winner2, true)
    end
  end

   # * Will reward the looser team with the predefined rewards Player got >= 10 points: 2 coins Player got < 10 points: 0 coins
   # * @param red
  private def reward_as_loser(red)
    temp_points = red ? @red_team_points : @blue_team_points
    temp_points.each do |player, value|
      if value >= 10
        player.add_item("Block Checker", 13067, 2, player, true)
      end
    end
  end

   # * Teleport players back, give status back and send final packet
  private def set_players_back
    _end = ExCubeGameEnd.new(@red_winner)

    @holder.not_nil!.all_players.each do |pc|
      pc.stop_all_effects
      # Remove team aura
      pc.team = Team::NONE
      # Set default arena
      pc.block_checker_arena = DEFAULT_ARENA
      # Remove the event items
      inv = pc.inventory
      if inv.get_item_by_item_id(13787)
        count = inv.get_inventory_item_count(13787, 0)
        inv.destroy_item_by_item_id("Handys Block Checker", 13787, count, pc, pc)
      end
      if inv.get_item_by_item_id(13788)
        count = inv.get_inventory_item_count(13788, 0)
        inv.destroy_item_by_item_id("Handys Block Checker", 13788, count, pc, pc)
      end
      broadcast_relation_changed(pc)
      # Teleport Back
      pc.tele_to_location(-57478, -60367, -2370)
      pc.inside_pvp_zone = false
      # Send end packet
      pc.send_packet(_end)
      pc.broadcast_user_info
    end
  end

  def end_event_task
    unless @abnormal_end
      reward_players
    end
    set_players_back
    clear_me
    @started = false
    @abnormal_end = false
  end
end
