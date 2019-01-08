class Condition
  class TargetAggro < Condition
    initializer is_aggro: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      case effected
      when L2MonsterInstance
        effected.aggressive? == @is_aggro
      when L2PcInstance
        effected.karma > 0
      else
        false
      end
    end
  end
end
