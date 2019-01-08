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

    if skill.has_effect_type?(L2EffectType::SUMMON) && target.servitor? && target.acting_player? && target.acting_player.l2id == char.l2id
      return EMPTY_TARGET_LIST
    end

    if skill.has_effect_type?(L2EffectType::HP_DRAIN) && target.old_corpse?(char.acting_player, Config.corpse_consume_skill_allowed_time_before_decay, true)
      return EMPTY_TARGET_LIST
    end

    [target] of L2Object
  end

  def target_type
    L2TargetType::CORPSE_MOB
  end
end
