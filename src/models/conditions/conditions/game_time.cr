class Condition
  class GameTime < Condition
    enum CheckGameTime : UInt8
      NIGHT
    end

    initializer check: CheckGameTime, required: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      @check.night? ? GameTimer.night? == @required : !@required
    end
  end
end
