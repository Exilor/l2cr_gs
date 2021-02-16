module TargetHandler::AuraCorpseMob
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target_list = nil

    max_targets = skill.affect_limit
    char.known_list.get_known_characters_in_radius(skill.affect_range) do |obj|
      if obj.attackable? && obj.dead?
        if only_first
          return [obj] of L2Object
        end

        if max_targets > 0 && target_list && target_list.size >= max_targets
          break
        end

        target_list ||= [] of L2Object
        target_list << obj
      end
    end

    target_list || EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::AURA_CORPSE_MOB
  end
end
