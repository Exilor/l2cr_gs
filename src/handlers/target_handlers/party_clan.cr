module TargetHandler::PartyClan
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    return [char] of L2Object if only_first
    return EMPTY_TARGET_LIST unless pc = char.acting_player
    target_list = [char] of L2Object

    has_clan = !!pc.clan
    has_party = !!pc.party
    radius = skill.affect_range

    if smn = add_summon(char, pc, radius, false)
      target_list << smn
    end

    unless has_clan || has_party
      return target_list
    end


    max_targets = skill.affect_limit

    pc.known_list.each_player(radius) do |obj|
      if pc.in_olympiad_mode?
        next unless obj.in_olympiad_mode?
        next if pc.olympiad_game_id != obj.olympiad_game_id
        next if pc.olympiad_side != obj.olympiad_side
      end

      if pc.in_duel?
        next if pc.duel_id != obj.duel_id
        if has_party && (party2 = obj.party)
          if pc.party != party2
            next
          end
        end
      end

      if !((has_clan && obj.clan_id == pc.clan_id) || (has_party && party2 && pc.party == obj.party))
        next
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

      return [obj] of L2Object if only_first

      if max_targets > 0 && target_list.size >= max_targets
        break
      end

      target_list << obj
    end

    target_list
  end

  def target_type : TargetType
    TargetType::PARTY_CLAN
  end
end
