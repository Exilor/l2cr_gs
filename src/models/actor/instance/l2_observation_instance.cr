class L2ObservationInstance < L2Npc
  def instance_type
    InstanceType::L2ObservationInstance
  end

  def show_chat_window(pc : L2PcInstance, val : Int32)
    if inside_radius?(-79884, 86529, 0, 50, false, true) || inside_radius?(-78858, 111358, 0, 50, false, true) || inside_radius?(-76973, 87136, 0, 50, false, true) || inside_radius?(-75850, 111968, 0, 50, false, true)
      if val == 0
        filename = "data/html/observation/#{id}-Oracle.htm";
      else
        filename = "data/html/observation/#{id}-Oracle-#{val}.htm";
      end
    else
      if val == 0
        filename = "data/html/observation/#{id}.htm";
      else
        filename = "data/html/observation/#{id}-#{val}.htm";
      end
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, filename)
    html["%objectId%"] = l2id
    pc.send_packet(html)
  end
end
