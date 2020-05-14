class Condition
  class PlayerMp < Condition
    initializer mp : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effector.mp_percent <= @mp
    end
  end
end
