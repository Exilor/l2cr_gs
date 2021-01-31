class Condition
  class TargetMyParty < self
    initializer except_me : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effected && skill
      return false unless pc = effected.acting_player

      if @except_me && pc == effected
        effector.send_packet(SystemMessageId::CANNOT_USE_ON_YOURSELF)
        return false
      end

      if pc.in_party?
        unless pc.in_party_with?(effected)
          sm = SystemMessage.s1_cannot_be_used
          sm.add_skill_name(skill)
          effector.send_packet(sm)
          return false
        end
      else
        if pc != effected.acting_player
          sm = SystemMessage.s1_cannot_be_used
          sm.add_skill_name(skill)
          effector.send_packet(sm)
          return false
        end
      end

      true
    end
  end
end
