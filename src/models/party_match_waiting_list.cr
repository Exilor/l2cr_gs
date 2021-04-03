module PartyMatchWaitingList
  extend self

  private PLAYERS = Concurrent::Set(L2PcInstance).new

  def players : Concurrent::Set(L2PcInstance)
    PLAYERS
  end

  def add_player(pc : L2PcInstance)
    PLAYERS << pc
  end

  def remove_player(pc : L2PcInstance)
    PLAYERS.delete(pc)
  end

  def find_players(min_lvl : Int32, max_lvl : Int32, classes : Set(Int32), filter : String) : Array(L2PcInstance)
    PLAYERS.select do |pc|
      pc.level.between?(min_lvl, max_lvl) &&
        (classes.empty? || classes.includes?(pc.class_id.to_i)) &&
        (filter.empty? || pc.name.downcase.includes?(filter.downcase)) &&
        pc.party_waiting?
    end
  end
end
