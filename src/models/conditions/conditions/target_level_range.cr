class Condition
  class TargetLevelRange < Condition
    initializer levels: Range(Int32, Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effected && @levels.includes?(effected.level)
    end
  end
end
