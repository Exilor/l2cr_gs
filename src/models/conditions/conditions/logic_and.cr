class Condition
  class LogicAnd < Condition
    getter conditions = Slice(Condition).empty

    def add(cond : Condition)
      if listener
        cond.listener = self
      end

      @conditions = @conditions.add(cond)
    end

    def listener=(listener : Listener)
      if listener
        @conditions.each &.listener = self
      else
        @conditions.each &.listener = nil
      end

      super
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      @conditions.all? &.test(effector, effected, skill, item)
    end
  end
end
