module TargetHandler::Ground
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target_list = [] of L2Object
    max_targets = skill.affect_limit
    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?

    pos = char.acting_player.current_skill_world_position.not_nil!
    char.known_list.each_character do |obj|
      if obj.inside_radius?(pos, skill.affect_range, false, false)
        if !Skill.check_for_area_offensive_skills(char, obj, skill, src_in_arena)
          next
        end

        next if obj.door?

        break if max_targets > 0 && target_list.size >= max_targets

        target_list << obj
      end
    end

    if target_list.empty? && skill.has_effect_type?(L2EffectType::SUMMON_NPC)
      target_list << char
    end

    target_list
  end

  def target_type
    L2TargetType::GROUND
  end
end
