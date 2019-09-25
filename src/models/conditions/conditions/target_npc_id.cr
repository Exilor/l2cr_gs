class Condition
  class TargetNpcId < Condition
    initializer npc_ids : Array(Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      (effected.is_a?(L2Npc) || effected.is_a?(L2DoorInstance)) &&
      @npc_ids.includes?(effected.id)
    end
  end
end
