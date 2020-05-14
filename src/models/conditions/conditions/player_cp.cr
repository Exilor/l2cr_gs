class Condition
  class PlayerCp < Condition
    initializer cp : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effector.cp_percent >= @cp
    end
  end
end
