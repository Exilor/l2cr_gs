class EffectHandler::Hide < AbstractEffect
  def on_start(info : BuffInfo)
    return unless pc = info.effected.as?(L2PcInstance)

    pc.invisible = true

    if pc.ai.next_intention.try &.intention.try &.attack?
      pc.intention = AI::IDLE
    end

    pc.known_list.each_character do |target|
      if target.target == pc
        target.target = nil
        target.abort_attack
        target.abort_cast
        target.intention = AI::IDLE
      end
    end
  end

  def on_exit(info : BuffInfo)
    return unless pc = info.effected.as?(L2PcInstance)
    return if pc.in_observer_mode?
    pc.invisible = false
  end
end
