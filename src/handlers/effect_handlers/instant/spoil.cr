class EffectHandler::Spoil < AbstractEffect
  def calc_success(info) : Bool
    ret = Formulas.magic_success(info.effector, info.effected, info.skill)
    if ret # custom, just pretty lights
      if sk = CommonSkill::FIREWORK.skill?
        pc = info.effector
        msu = MagicSkillUse.new(pc, info.effected, sk.id, sk.level, sk.hit_time, sk.reuse_delay)
        pc.broadcast_packet(msu)
      end
    end
    ret
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    effector, target = info.effector, info.effected

    if !target.monster? || target.dead?
      effector.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    target = target.as(L2MonsterInstance)

    if target.spoiled?
      effector.send_packet(SystemMessageId::ALREADY_SPOILED)
      return
    end

    target.spoiler_l2id = effector.l2id
    effector.send_packet(SystemMessageId::SPOIL_SUCCESS)
    target.notify_event(AI::ATTACKED, effector)
  end
end
