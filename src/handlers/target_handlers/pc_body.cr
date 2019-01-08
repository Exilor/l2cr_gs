module TargetHandler::PcBody
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if target
      player = char.acting_player if char.player?
      target_player = target.acting_player if target.player?
      target_pet = target if target.pet?
    end

    good_cond = false

    if player && (target_player || target_pet)
      good_cond = true
      if skill.has_effect_type?(L2EffectType::RESURRECTION)
        if target_player
          if target_player.inside_siege_zone? && !target_player.in_siege?
            good_cond = false
            char.send_packet(SystemMessageId::CANNOT_BE_RESURRECTED_DURING_SIEGE)
          end

          if target_player.festival_participant?
            good_cond = false
            char.send_message("You may not resurrect participants in a festival.")
          end
        end
      end

      return [target.not_nil!] of L2Object if good_cond
    end

    char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)

    EMPTY_TARGET_LIST
  end

  def target_type
    L2TargetType::PC_BODY
  end
end
