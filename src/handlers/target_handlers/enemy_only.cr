module TargetHandler::EnemyOnly
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if skill.affect_scope.single?
      unless target
        return EMPTY_TARGET_LIST
      end

      if target.dead?
        char.send_packet(SystemMessageId::INCORRECT_TARGET)
        return EMPTY_TARGET_LIST
      end

      pc = char.acting_player

      if !target.attackable? && pc && !pc.in_party_with?(target)
        if !pc.in_clan_with?(target) && !pc.in_ally_with?(target)
          if !pc.in_command_channel_with?(target) && !pc.check_if_pvp(target)
            unless pc.in_duel_with?(target)
              char.send_packet(SystemMessageId::INCORRECT_TARGET)
              return EMPTY_TARGET_LIST
            end
          end
        end
      end

      return [target] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::ENEMY_ONLY
  end
end
