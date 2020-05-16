struct TvTEventPlayer
  getter_initializer player : L2PcInstance

  def on_event? : Bool
    TvTEvent.started? && TvTEvent.participant?(player.l2id)
  end

  def blocking_exit? : Bool
    true
  end

  def blocking_death_penalty? : Bool
    true
  end

  def can_revive? : Bool
    false
  end
end
