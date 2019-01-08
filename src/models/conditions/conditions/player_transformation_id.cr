class Condition
  class PlayerTransformationId < Condition
    initializer id: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player?
      @id == -1 ? pc.transformed? : pc.transformation_id == @id
    end
  end
end
