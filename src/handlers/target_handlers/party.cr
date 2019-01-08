module TargetHandler::Party
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target_list = [char] of L2Object
    return target_list if only_first

    radius = skill.affect_range

    if char.summon?
      pc = char.acting_player
      if Skill.add_character(char, pc, radius, false)
        target_list << pc
      end
    elsif char.player?
      pc = char.acting_player
      if Skill.add_summon(char, pc, radius, false)
        target_list << pc.summon!
      end
    end

    if char.in_party?
      char.party.each do |m|
        next if m == pc

        if Skill.add_character(char, m, radius, false)
          target_list << m
        end

        if Skill.add_summon(char, m, radius, false)
          target_list << m.summon!
        end
      end
    end

    target_list
  end

  def target_type
    L2TargetType::PARTY
  end
end
