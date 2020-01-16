class EffectHandler::ConsumeBody < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info)
    target = info.effected

    if target.is_a?(L2Npc) && target.dead?
      target.end_decay_task
    end
  end
end
