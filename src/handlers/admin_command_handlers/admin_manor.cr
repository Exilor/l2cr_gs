module AdminCommandHandler::AdminManor
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    msg = NpcHtmlMessage.new
    msg.set_file(pc, "data/html/admin/manor.htm")
    msg["%status%"] = CastleManorManager.current_mode_name
    msg["%change%"] = CastleManorManager.next_mode_change

    str = String.build(3400) do |io|
      CastleManager.castles.each do |c|
        io << "<tr><td>Name:</td><td><font color=008000>"
        io << c.name
        io << "</font></td></tr>" \
              "<tr><td>Current period cost:</td><td><font color=FF9900>"
        cost = CastleManorManager.get_manor_cost(c.residence_id, false)
        io << Util.format_adena(cost)
        io << " Adena</font></td></tr>" \
              "<tr><td>Next period cost:</td><td><font color=FF9900>"
        cost = CastleManorManager.get_manor_cost(c.residence_id, true)
        io << Util.format_adena(cost)
        io << " Adena</font></td></tr>" \
              "<tr><td><font color=808080>--------------------------</font></td><td><font color=808080>--------------------------</font></td></tr>"
      end
    end

    msg["%castleInfo%"] = str

    pc.send_packet(msg)

    true
  end

  def commands : Enumerable(String)
    {"admin_manor"}
  end
end
