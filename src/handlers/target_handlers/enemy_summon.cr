module TargetHandler::EnemySummon
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    return EMPTY_TARGET_LIST unless target.is_a?(L2Summon)

    unless char.player? && char.summon != target
      return EMPTY_TARGET_LIST
    end

    pc = char.as?(L2PcInstance)
    owner = target.owner

    if pc && char.summon != target && target.alive?
      if owner.pvp_flag != 0 || owner.karma > 0
        return [target] of L2Object
      end
    end

    if owner.inside_pvp_zone? && (pc && pc.inside_pvp_zone?)
      return [target] of L2Object
    end

    if owner.in_duel? && pc && (pc.in_duel? && owner.duel_id == pc.duel_id)
      return [target] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::ENEMY_SUMMON
  end
end
