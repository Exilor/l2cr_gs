module PartyMatchWaitingList
  extend self
  extend Synchronizable

  private PLAYERS = Set(L2PcInstance).new

  def players : Set(L2PcInstance)
    PLAYERS
  end

  def add_player(pc : L2PcInstance)
    PLAYERS << pc
  end

  def remove_player(pc : L2PcInstance)
    PLAYERS.delete(pc)
  end
end
