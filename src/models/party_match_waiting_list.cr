module PartyMatchWaitingList
  extend self

  private PLAYERS = Concurrent::Set(L2PcInstance).new

  def players : ISet(L2PcInstance)
    PLAYERS
  end

  def add_player(pc : L2PcInstance)
    PLAYERS << pc
  end

  def remove_player(pc : L2PcInstance)
    PLAYERS.delete(pc)
  end
end
