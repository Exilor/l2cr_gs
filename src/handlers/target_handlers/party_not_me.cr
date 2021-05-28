module TargetHandler::PartyNotMe
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
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

      if (smn = m.summon) && smn.alive?
        target_list << smn
      end
    end

    target_list
  end

  def target_type : TargetType
    TargetType::PARTY_NOTME
  end
end
