class EffectHandler::UnsummonAgathion < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    return unless pc = info.effector.acting_player?
    pc.agathion_id = 0
    pc.broadcast_user_info
  end
end
