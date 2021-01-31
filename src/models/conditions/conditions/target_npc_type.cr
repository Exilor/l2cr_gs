require "../../../enums/instance_type"

class Condition
  class TargetNpcType < self
    @npc_types : Slice(InstanceType)

    def initialize(npc_types)
      @npc_types = npc_types.to_slice
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effected && effected.instance_type.types?(@npc_types)
    end
  end
end
