module TargetHandler::AuraUndeadEnemy
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target_list = nil
    max_targets = skill.affect_limit

    char.known_list.each_character(skill.affect_range) do |obj|
      if obj.attackable? && obj.undead?
        if only_first
          return [obj] of L2Object
        end

        if target_list && max_targets > 0 && target_list.size >= max_targets
          break
        end

        target_list ||= [] of L2Object
        target_list << obj
      end
    end

    target_list || EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::AURA_UNDEAD_ENEMY
  end
end
