class Condition
  class PlayerHasAgathion < self
    initializer expected : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.as?(L2PcInstance)
      @expected == pc.agathion_id > 0
    end
  end
end
