module TargetHandler::Aura
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target_list = [] of L2Object

    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?

    char.known_list.each_character(skill.affect_range) do |obj|
      unless obj.attackable? || obj.playable? || obj.door? || obj.trap?
        next
      end

      if obj.is_a?(L2DoorInstance) && !obj.template.stealth?
        next
      end

      if !Skill.check_for_area_offensive_skills(char, obj, skill, src_in_arena)
        next
      end

      if char.playable? && obj.attackable? && !skill.bad?
        next
      end

      target_list << obj
      break if only_first
    end

    target_list
  end

  def target_type
    L2TargetType::AURA
  end
end
