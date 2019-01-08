class Condition
  class TargetMyPartyExceptMe < Condition
    initializer val: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effected && skill

      is_party_member = true
      pc = effector.acting_player?
      if pc.nil?
        unless effected.player?
          sm = SystemMessage.s1_cannot_be_used
          sm.add_skill_name(skill)
          effector.send_packet(sm)
        end

        is_party_member = false
      elsif pc == effected
        pc.send_packet(SystemMessageId::CANNOT_USE_ON_YOURSELF)
        is_party_member = false
      elsif !pc.in_party? || pc.party != effected.party?
        sm = SystemMessage.s1_cannot_be_used
        sm.add_skill_name(skill)
        pc.send_packet(sm)
        is_party_member = false
      end

      @val == is_party_member
    end
  end
end
