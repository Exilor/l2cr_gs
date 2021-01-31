class EffectHandler::OpenDoor < AbstractEffect
  @chance : Int32
  @is_item : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super

    @chance = params.get_i32("chance", 0)
    @is_item = params.get_bool("isItem", false)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effector, door = info.effector, info.effected
    return unless door.is_a?(L2DoorInstance)

    if effector.instance_id != door.instance_id
      inst = InstanceManager.get_instance(effector.instance_id)
      return unless inst
      if inst_door = inst.get_door(door.id)
        door = inst_door
      end

      return if effector.instance_id != door.instance_id
    end

    if (!door.openable_by_skill? && !@is_item) || door.fort?
      effector.send_packet(SystemMessageId::UNABLE_TO_UNLOCK_DOOR)
      return
    end

    if Rnd.rand(100) < @chance && door.closed?
      door.open_me
    else
      effector.send_packet(SystemMessageId::FAILED_TO_UNLOCK_DOOR)
    end
  end
end
