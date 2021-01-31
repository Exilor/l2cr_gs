class EffectHandler::DetectHiddenObjects < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    door = info.effected
    return unless door.is_a?(L2DoorInstance)

    if door.template.stealth?
      door.mesh_index = 1
      door.targetable = door.template.open_type != 0
      door.broadcast_status_update
    end
  end
end
