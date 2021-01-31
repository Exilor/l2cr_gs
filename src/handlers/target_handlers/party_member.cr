module TargetHandler::PartyMember
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    unless target
      if char.playable?
        char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      end

      return EMPTY_TARGET_LIST
    end

    if target.alive?
      if target == char || ((p1 = char.party) && (p2 = target.party) &&
        p1 == p2) ||
        (char.player? && target.summon? && char.summon == target) ||
        (char.summon? && target.player? && char == target.summon)

        return [target] of L2Object
      end
    end

    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::PARTY_MEMBER
  end
end
