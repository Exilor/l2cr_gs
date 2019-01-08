module TargetHandler::EnemySummon
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    return EMPTY_TARGET_LIST unless target.is_a?(L2Summon)

    unless char.player? && char.summon != target
      return EMPTY_TARGET_LIST
    end

    if ((char.player? && (char.summon != target) &&
      target.alive? && ((target.owner.pvp_flag != 0) || (target.owner.karma > 0))) ||
      (target.owner.inside_pvp_zone? && char.acting_player.inside_pvp_zone?) ||
      (target.owner.in_duel? && char.acting_player.in_duel? && (target.owner.duel_id == char.acting_player.duel_id)))

      return [target] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    L2TargetType::ENEMY_SUMMON
  end
end
