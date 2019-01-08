module ActionShiftHandler::L2ItemInstanceAction
  extend self
  extend ActionShiftHandler

  def action(pc, target, interact)
    if pc.access_level.gm?
      item = target.unsafe_as(L2ItemInstance)
      str = String.build do |io|
        io << "<html><body><center><font color=\"LEVEL\">Item Info</font></center><br><table border=0>"
        io << "<tr><td>Object ID: </td><td>"
        io << item.l2id
        io << "</td></tr><tr><td>Item ID: </td><td>"
        io << item.id
        io << "</td></tr><tr><td>Owner ID: </td><td>"
        io << item.owner_id
        io << "</td></tr><tr><td>Location: </td><td>"
        io << item.location
        io << "</td></tr><tr><td><br></td></tr><tr><td>Class: </td><td>"
        io << item.class.simple_name
        io << "</td></tr></table></body></html>"
      end
      html = NpcHtmlMessage.new(str)
      pc.send_packet(html)
    end

    true
  end

  def instance_type
    InstanceType::L2ItemInstance
  end
end
