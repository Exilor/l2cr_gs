module TargetHandler::CorpseClan
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    debug "#{skill}, #{char}, #{target}"
    target_list = nil

    if char.playable?
      unless pc = char.acting_player?
        return EMPTY_TARGET_LIST
      end

      if pc.in_olympiad_mode?
        return [pc] of L2Object
      end

      clan = pc.clan?

      if clan
        radius = skill.affect_range
        max_targets = skill.affect_limit

        clan.members.each do |m|
          next unless obj = m.player?

          next if obj == pc

          if pc.in_duel?
            if pc.duel_id != obj.duel_id
              next
            end

            if pc.in_party? && obj.in_party?
              if pc.party.leader_l2id != obj.party.leader_l2id
                next
              end
            end
          end

          unless pc.check_pvp_skill(obj, skill)
            next
          end

          # unless TvTEvent.check_for_tvt_skill(pc, obj, skill)
          #   next
          # end

          unless Skill.add_character(char, obj, radius, false)
            next
          end

          if obj.inside_siege_zone? && !obj.in_siege?
            next
          end

          if only_first
            return [obj] of L2Object
          end

          target_list ||= [] of L2Object

          if max_targets > 0 && target_list.size >= max_targets
            break
          end

          target_list << obj
        end
      end
    elsif char.is_a?(L2Npc)
      npc = char

      if npc.template.clans.empty?
        return [char] of L2Object
      end

      target_list = [char] of L2Object

      max_targets = skill.affect_limit
      char.known_list.known_objects.each_value do |new_target|
        if new_target.is_a?(L2Npc) && npc.in_my_clan?(new_target)
          unless Util.in_range?(skill.cast_range, char, new_target, true)
            next
          end

          if max_targets > 0 && target_list.size >= max_targets
            break
          end

          target_list << new_target
        end
      end
    end

    debug "target list: #{target_list}"

    target_list || EMPTY_TARGET_LIST
  end

  def target_type
    L2TargetType::CORPSE_CLAN
  end
end
