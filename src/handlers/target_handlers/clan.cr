module TargetHandler::Clan
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if char.playable?
      unless pc = char.acting_player
        return EMPTY_TARGET_LIST
      end

      if pc.in_olympiad_mode?
        return EMPTY_TARGET_LIST
      end

      if only_first
        return [pc] of L2Object
      end

      target_list = [pc] of L2Object

      radius = skill.affect_range
      clan = pc.clan

      if smn = add_summon(char, pc, radius, false)
        target_list << smn
      end

      if clan
        clan.members.each do |m|
          obj = m.player_instance

          next if obj.nil? || obj == pc

          if pc.in_duel?
            if pc.duel_id != obj.duel_id
              next
            end

            if pc.party && obj.party && pc.party != obj.party
              next
            end
          end

          unless pc.check_pvp_skill(obj, skill)
            next
          end

          unless TvTEvent.check_for_tvt_skill(pc, obj, skill)
            next
          end

          if !only_first && (smn = add_summon(char, obj, radius, false))
            target_list << smn
          end

          unless add_character(char, obj, radius, false)
            next
          end

          if only_first
            return [obj] of L2Object
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
      char.known_list.each_object do |new_target|
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

    target_list || EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::CLAN
  end
end
