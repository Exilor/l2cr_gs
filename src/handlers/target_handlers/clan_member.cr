module TargetHandler::ClanMember
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target_list = nil

    if npc = char.as?(L2Npc)
      if npc.template.clans.empty?
        return [npc] of L2Object
      end

      npc.known_list.known_objects.each_value do |obj|
        if obj.is_a?(L2Npc) && npc.in_my_clan?(obj)
          unless Util.in_range?(skill.cast_range, char, obj, true)
            next
          end

          if obj.affected_by_skill?(skill.id)
            next
          end

          target_list ||= [] of L2Object
          target_list << obj
          break
        end
      end

      unless target_list
        return [npc] of L2Object
      end
    end

    target_list || EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::CLAN_MEMBER
  end
end
