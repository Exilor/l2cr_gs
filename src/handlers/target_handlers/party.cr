module TargetHandler::Party
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    target_list = [char] of L2Object
    return target_list if only_first

    radius = skill.affect_range

    if char.is_a?(L2Summon)
      pc = char.owner
      if add_character(char, pc, radius, false)
        target_list << pc
      end
    elsif pc = char.as?(L2PcInstance)
      if smn = add_summon(char, pc, radius, false)
        target_list << smn
      end
    end

    if party = char.party
      party.each do |m|
        next if m == pc

        if add_character(char, m, radius, false)
          target_list << m
        end

        if smn = add_summon(char, m, radius, false)
          target_list << smn
        end
      end
    end

    target_list
  end

  def target_type : TargetType
    TargetType::PARTY
  end
end
