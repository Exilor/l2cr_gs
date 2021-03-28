class EffectHandler::Spoil < AbstractEffect
  def calc_success(info) : Bool
    Formulas.magic_success(info.effector, info.effected, info.skill)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effector, target = info.effector, info.effected

    if !target.is_a?(L2MonsterInstance) || target.dead?
      effector.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    if target.spoiled?
      effector.send_packet(SystemMessageId::ALREADY_SPOILED)
      return
    end

    target.spoiler_l2id = effector.l2id
    effector.send_packet(SystemMessageId::SPOIL_SUCCESS)
    target.notify_event(AI::ATTACKED, effector)
  end
end
