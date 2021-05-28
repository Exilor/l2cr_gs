module TargetHandler::TargetParty
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    target_list = [char] of L2Object
    return target_list if only_first

    return target_list unless player = char.acting_player
    radius = skill.affect_range

    if char.summon?
      if add_character(char, player, radius, false)
        target_list << player
      end
    elsif char.player?
      if smn = add_summon(char, player, radius, false)
        target_list << smn
      end
    end

    if party = char.party
      party.members.each do |m|
        next if m == player
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
    TargetType::TARGET_PARTY
  end
end
