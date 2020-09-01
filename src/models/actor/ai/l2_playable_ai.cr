require "./l2_character_ai"

class L2PlayableAI < L2CharacterAI
  private def on_intention_attack(target : L2Character?)
    return unless target

    if target.playable? && (pc_target = target.acting_player)
      if pc_target.protection_blessing_affected?
        if pc_target.level &- @actor.level >= 10
          if pc_target.karma > 0 && target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            return
          end
        end
      end

      me = @actor.acting_player.not_nil!

      if me.protection_blessing_affected?
        if pc_target.level &- @actor.level >= 10
          if pc_target.karma > 0 && !target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            return
          end
        end
      end

      if pc_target.cursed_weapon_equipped? && @actor.level <= 20
        @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        client_action_failed
        return
      end

      if me.cursed_weapon_equipped?
        if pc_target.level <= 20
          @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
          client_action_failed
          return
        end
      end
    end

    super
  end

  private def on_intention_cast(skill : Skill, target : L2Object?)
    return super unless target.is_a?(L2Playable)

    if (pc_target = target.acting_player) && skill.bad?
      me = @actor.acting_player.not_nil!
      if pc_target.protection_blessing_affected?
        if @actor.level &- pc_target.level >= 10
          if me.karma > 0 && !target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            @actor.casting_now = false
            return
          end
        end
      end

      if me.protection_blessing_affected?
        if pc_target.level &- @actor.level >= 10
          if pc_target.karma > 0 && !target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            @actor.casting_now = false
            return
          end
        end
      end

      if pc_target.cursed_weapon_equipped?
        if @actor.level <= 20 || pc_target.level <= 20
          @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
          client_action_failed
          @actor.casting_now = false
          return
        end
      end
    end

    super
  end
end
