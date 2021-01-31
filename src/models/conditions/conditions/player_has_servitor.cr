class Condition
  class PlayerHasServitor < self
    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      unless pc.has_summon?
        effector.send_packet(SystemMessageId::CANNOT_USE_SKILL_WITHOUT_SERVITOR)
        return false
      end

      true
    end
  end
end
