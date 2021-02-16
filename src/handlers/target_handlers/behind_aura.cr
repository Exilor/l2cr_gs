module TargetHandler::BehindAura
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target_list = [] of L2Object
    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?
    max_targets = skill.affect_limit

    char.known_list.get_known_characters_in_radius(skill.affect_range) do |obj|
      next unless obj.attackable? || obj.playable?
      next unless obj.behind?(char)
      unless skill.offensive_aoe_check(char, obj, src_in_arena)
        next
      end

      if only_first
        target_list << obj
        break
      end

      break if max_targets > 0 && target_list.size >= max_targets

      target_list << obj
    end

    target_list
  end

  def target_type : TargetType
    TargetType::BEHIND_AURA
  end
end
