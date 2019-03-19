struct NpcAI::NpcBufferAI
  include Runnable
  include Loggable

  initializer npc: L2Npc, skill_data: NpcBufferSkillData

  def run
    # unless @npc
    #   warn "No NPC."
    #   return
    # end

    skill = @skill_data.skill

    unless @npc.visible?
      # warn 'NPC is not visible.'
      return
    end

    if @npc.decayed?
      warn "NPC is decayed."
      return
    end

    if @npc.dead?
      warn "NPC is dead."
      return
    end

    summoner = @npc.summoner?

    unless summoner && summoner.player?
      warn "Summoner is nil or not a player."
      return
    end

    pc = summoner.acting_player

    case @skill_data.affect_scope
    when AffectScope::PARTY
      if pc.in_party?
        pc.party.members.each do |m|
          if m.alive? && Util.in_range?(skill.affect_range, @npc, m, true)
            skill.apply_effects(pc, m)
          end
        end
      else
        if pc.alive? && Util.in_range?(skill.affect_range, @npc, pc, true)
          skill.apply_effects(pc, pc)
        end
      end
    when AffectScope::RANGE
      @npc.known_list.each_character(skill.affect_range) do |target|
        case @skill_data.affect_object
        when AffectObject::FRIEND
          if friendly?(pc, target) && target.alive?
            skill.apply_effects(target, target)
          end
        when AffectObject::NOT_FRIEND
          if enemy?(pc, target) && target.alive?
            if target.playable?
              pc.update_pvp_status(target)
            end

            skill.apply_effects(target, target)
          end
        end
      end
    end

    ThreadPoolManager.schedule_general(self, @skill_data.delay)
  end

  def friendly?(pc, target)
    return false unless target.playable?

    target_player = target.acting_player

    case
    when pc == target_player
      true
    when pc.in_party_with?(target_player)
      true
    when pc.in_clan_with?(target_player)
      true
    when pc.in_ally_with?(target_player)
      true
    when pc.on_same_siege_side_with?(target_player)
      true
    else
      false
    end
  end

  def enemy?(pc, target)
    if friendly?(pc, target)
      return false
    end

    if target.is_a?(L2TamedBeastInstance)
      return enemy?(pc, target.owner)
    end

    if target.monster?
      return true
    end

    return false unless target.playable?

    target_player = target.acting_player
    if friendly?(pc, target_player)
      return false
    end

    case
    when target_player.pvp_flag != 0
      true
    when target_player.karma != 0
      true
    when pc.at_war_with?(target_player)
      true
    when target_player.inside_pvp_zone?
      true
    else
      false
    end
  end
end
