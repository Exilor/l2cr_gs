class Condition
  class PlayerCanResurrect < Condition
    initializer val: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      skill = skill.not_nil!
      return true if skill.affect_range > 0
      return false unless effected

      can_res = true

      if effected.player?
        player = effected.acting_player

        if player.alive?
          can_res = false
          if effector.player?
            sm = SystemMessage.s1_cannot_be_used
            sm.add_skill_name(skill)
            effector.send_packet(sm)
          end
        elsif player.resurrection_blocked?
          can_res = false
          if effector.player?
            effector.send_packet(SystemMessageId::REJECT_RESURRECTION)
          end
        elsif player.revive_requested?
          can_res = false
          if effector.player?
            effector.send_packet(SystemMessageId::RES_HAS_ALREADY_BEEN_PROPOSED)
          end
        end
      elsif effected.is_a?(L2Summon)
        summon = effected
        player = summon.owner

        if summon.alive?
          sm = SystemMessage.s1_cannot_be_used
          sm.add_skill_name(skill)
          effector.send_packet(sm)
        elsif summon.resurrection_blocked?
          can_res = false
          if effector.player?
            effector.send_packet(SystemMessageId::REJECT_RESURRECTION)
          end
        elsif !player && player.reviving_pet?
          can_res = false
          if effector.player?
            effector.send_packet(SystemMessageId::RES_HAS_ALREADY_BEEN_PROPOSED)
          end
        end
      end

      @val == can_res
    end
  end
end
