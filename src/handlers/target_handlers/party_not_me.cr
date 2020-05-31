module TargetHandler::PartyNotMe
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    unless party = char.party
      return EMPTY_TARGET_LIST
    end

    target_list = Array(L2Object).new(party.members.size &- 1)

    party.members.each do |m|
      next if m.dead? || char == m
      next unless Util.in_range?(Config.alt_party_range, char, m, true)
      range = skill.affect_range
      next if range > 0 && !Util.in_range?(range, char, m, true)


      target_list << m

      if summon = m.summon
        if summon.alive?
          target_list << summon
        end
      end
    end

    target_list
  end

  def target_type
    TargetType::PARTY_NOTME
  end
end
