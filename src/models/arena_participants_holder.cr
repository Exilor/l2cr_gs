require "./entity/block_checker_engine"

struct ArenaParticipantsHolder
  include Synchronizable

  getter red_players, blue_players
  getter! event : BlockCheckerEngine

  def initialize(arena : Int32)
    @arena = arena
    @red_players = Array(L2PcInstance).new(6)
    @blue_players = Array(L2PcInstance).new(6)
    @event = BlockCheckerEngine.new(self, arena)
  end

  def each_player(& : L2PcInstance ->)
    @red_players.each { |pc| yield pc }
    @blue_players.each { |pc| yield pc }
  end

  def size : Int32
    red_team_size + blue_team_size
  end

  def includes?(pc : L2PcInstance) : Bool
    @red_players.includes?(pc) || @blue_players.includes?(pc)
  end

  def add_player(pc : L2PcInstance, team : Int32)
    (team == 0 ? @red_players : @blue_players) << pc
  end

  def remove_player(pc : L2PcInstance, team : Int32)
    (team == 0 ? @red_players : @blue_players).delete_first(pc)
  end

  def get_player_team(pc : L2PcInstance) : Int32
    @red_players.includes?(pc) ? 0 : @blue_players.includes?(pc) ? 1 : -1
  end

  def red_team_size : Int32
    @red_players.size
  end

  def blue_team_size : Int32
    @blue_players.size
  end

  def broadcast_packet_to_team(gsp : GameServerPacket | SystemMessageId)
    each_player { |pc| pc.send_packet(gsp) }
  end

  def clear_players
    @red_players.clear
    @blue_players.clear
  end

  def update_event
    event.update_players_on_start(self)
  end

  def check_and_shuffle
    red_size = @red_players.size
    blue_size = @blue_players.size

    if red_size > blue_size + 1
      broadcast_packet_to_team(SystemMessageId::TEAM_ADJUSTED_BECAUSE_WRONG_POPULATION_RATIO)
      needed = red_size - (blue_size + 1)
      (needed + 1).times do |i|
        pc = @red_players[i]
        HandysBlockCheckerManager.change_player_to_team(pc, @arena, 1)
      end
    elsif blue_size > red_size + 1
      broadcast_packet_to_team(SystemMessageId::TEAM_ADJUSTED_BECAUSE_WRONG_POPULATION_RATIO)
      needed = blue_size - (red_size + 1)
      (needed + 1).times do |i|
        pc = @blue_players[i]
        HandysBlockCheckerManager.change_player_to_team(pc, @arena, 0)
      end
    end
  end
end
