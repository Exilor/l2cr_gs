module ActionShiftHandler::L2StaticObjectInstanceAction
  extend self
  extend ActionShiftHandler

  def action(pc, target, interact)
    if pc.access_level.gm?
      pc.target = target
      obj = target.unsafe_as(L2StaticObjectInstance)

      pc.send_packet(StaticObject.new(obj))
      str = String.build do |io|
        io << "<html><body><center><font color=\"LEVEL\">Static Object Info</font></center><br><table border=0><tr><td>Coords X,Y,Z: </td><td>"
        io << obj.x
        io << ", "
        io << obj.y
        io << ", "
        io << obj.z
        io << "</td></tr><tr><td>Object ID: </td><td>"
        io << obj.l2id
        io << "</td></tr><tr><td>Static Object ID: </td><td>"
        io << obj.id
        io << "</td></tr><tr><td>Mesh Index: </td><td>"
        io << obj.mesh_index
        io << "</td></tr><tr><td><br></td></tr><tr><td>Class: </td><td>"
        io << obj.class.simple_name
        io << "</td></tr></table></body></html>"
      end
      html = NpcHtmlMessage.new(str)
      pc.send_packet(html)
    end

    true
  end

  def instance_type
    InstanceType::L2StaticObjectInstance
  end
end
