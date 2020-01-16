module TargetHandler::CorpseMob
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    unless target
      char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    unless target.is_a?(L2Attackable) && target.dead?
      char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    if skill.has_effect_type?(EffectType::SUMMON) && target.servitor?
      if (pc = target.acting_player) && pc.l2id == char.l2id
        return EMPTY_TARGET_LIST
      end
    end

    if skill.has_effect_type?(EffectType::HP_DRAIN)
      time = Config.corpse_consume_skill_allowed_time_before_decay
      if target.old_corpse?(char.acting_player, time, true)
        return EMPTY_TARGET_LIST
      end
    end

    [target] of L2Object
  end

  def target_type
    TargetType::CORPSE_MOB
  end
end
