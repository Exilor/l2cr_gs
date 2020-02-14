class Condition
  class TargetNpcId < Condition
    @npc_ids : Slice(Int32)

    def initialize(npc_ids)
      @npc_ids = npc_ids.sort.to_slice
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      (effected.is_a?(L2Npc) || effected.is_a?(L2DoorInstance)) &&
      @npc_ids.includes?(effected.id)
    end
  end
end
