class Condition
  class LogicNot < Condition
    def initialize(@condition : Condition)
      if listener
        condition.listener = self
      end
    end

    def listener=(lst : Listener?)
      @condition.listener = lst ? self : nil
      super
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !@condition.test(effector, effected, skill, item)
    end
  end
end
