require "../../../enums/instance_type"

class Condition
  class TargetNpcType < Condition
    initializer npc_types : Array(InstanceType)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effected && effected.instance_type.types?(@npc_types)
    end
  end
end
