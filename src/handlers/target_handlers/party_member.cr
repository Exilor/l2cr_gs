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
      if (target == char) || (char.in_party? && target.in_party? &&
        (char.party.leader_l2id == target.party.leader_l2id)) ||
        (char.player? && target.summon? && (char.summon == target)) ||
        (char.summon? && target.player? && (char == target.summon))

        return [target] of L2Object
      end
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    L2TargetType::PARTY_MEMBER
  end
end
