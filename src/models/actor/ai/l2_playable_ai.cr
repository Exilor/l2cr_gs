require "./l2_character_ai"

class L2PlayableAI < L2CharacterAI
  def on_intention_attack(target)
    if target.playable?
      if target.acting_player.protection_blessing_affected?
        if target.acting_player.level - @actor.level >= 10
          if target.acting_player.karma > 0 && target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            return
          end
        end
      end

      if @actor.acting_player.protection_blessing_affected?
        if target.acting_player.level - @actor.level >= 10
          if target.acting_player.karma > 0 && !target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            return
          end
        end
      end

      if target.acting_player.cursed_weapon_equipped? && @actor.level <= 20
        @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        client_action_failed
        return
      end

      if @actor.acting_player.cursed_weapon_equipped?
        if target.acting_player.level <= 20
          @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
          client_action_failed
          return
        end
      end
    end

    super
  end

  def on_intention_cast(skill : Skill, target : L2Object?)
    # debug "L2PlayableAI#on_intention_cast(#{skill}, #{target})"
    if target.is_a?(L2Playable) && skill.bad?
      if target.acting_player.protection_blessing_affected?
        if @actor.level - target.acting_player.level >= 10
          if @actor.acting_player.karma > 0 && !target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            @actor.casting_now = false
            return
          end
        end
      end

      if @actor.acting_player.protection_blessing_affected?
        if target.acting_player.level - @actor.level >= 10
          if target.acting_player.karma > 0 && !target.inside_pvp_zone?
            @actor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
            client_action_failed
            @actor.casting_now = false
            return
          end
        end
      end

      if target.acting_player.cursed_weapon_equipped?
        if @actor.level <= 20 || target.acting_player.level <= 20
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
