module ActionShiftHandler::L2DoorInstanceActionShift
  extend self
  extend ActionShiftHandler

  def action(pc, target, interact) : Bool
    if pc.access_level.gm?
      pc.target = target
      door = target
      unless door.is_a?(L2DoorInstance)
        raise "Expected #{door}:#{door.class} to be a L2DoorInstance"
      end
      html = NpcHtmlMessage.new

      html.set_file(pc, "data/html/admin/doorinfo.htm")

      html["%class%"] = door.class.simple_name
      html["%hp%"] = door.current_hp.to_i
      html["%hpmax%"] = door.max_hp
      html["%objid%"] = door.l2id
      html["%doorid%"] = door.id

      html["%minx%"] = door.get_x(0)
      html["%miny%"] = door.get_y(0)
      html["%minz%"] = door.z_min

      html["%maxx%"] = door.get_x(2)
      html["%maxy%"] = door.get_y(2)
      html["%maxz%"] = door.z_max
      if door.openable_by_skill?
        html["%unlock%"] = "<font color=00FF00>YES<font>"
      else
        html["%unlock%"] = "<font color=FF0000>NO</font>"
      end

      pc.send_packet(html)
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2DoorInstance
  end
end
