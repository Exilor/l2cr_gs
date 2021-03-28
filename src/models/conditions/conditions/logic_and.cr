class Condition
  class LogicAnd < self
    getter conditions = Slice(Condition).empty

    def add(cond : Condition)
      @conditions = @conditions.add(cond)
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      @conditions.all? &.test(effector, effected, skill, item)
    end
  end
end
