class Condition
  class PlayerLevelRange < Condition
    initializer levels : Range(Int32, Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      @levels.includes?(effector.level)
    end
  end
end
