class Condition
  class PlayerInstanceId < Condition
    initializer ids : Array(Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      instance_id = effector.instance_id
      return false if instance_id <= 0
      world = InstanceManager.get_player_world(pc)
      return false unless world
      return false unless world.instance_id == instance_id
      @ids.includes?(world.template_id)
    end
  end
end
