class Condition
  class PlayerCp < Condition
    initializer cp : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effector && (effector.current_cp * 100) / effector.max_cp >= @cp
    end
  end
end
