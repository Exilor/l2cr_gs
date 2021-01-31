class EffectHandler::UnsummonAgathion < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.acting_player
    pc.agathion_id = 0
    pc.broadcast_user_info
  end
end
