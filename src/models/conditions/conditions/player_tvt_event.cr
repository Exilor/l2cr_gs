class Condition
  class PlayerTvTEvent < Condition
    initializer val: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      debug "Not implemented."
      false
    end
  end
end
