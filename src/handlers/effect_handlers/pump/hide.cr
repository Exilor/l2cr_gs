class EffectHandler::Hide < AbstractEffect
  def on_start(info)
    return unless pc = info.effected.acting_player?

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

  def on_exit(info)
    return unless info.effected.player?
    pc = info.effected.acting_player
    unless pc.in_observer_mode?
      pc.invisible = false
    end
  end
end
