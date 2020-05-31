class L2DoormenInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2DoormenInstance
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    if command.starts_with?("Chat")
      show_chat_window(pc)
      return
    elsif command.starts_with?("open_doors")
      if owner_clan?(pc)
        if under_siege?
          cannot_manage_doors(pc)
        else
          open_doors(pc, command)
        end
      end

      return
    elsif command.starts_with?("close_doors")
      if owner_clan?(pc)
        if under_siege?
          cannot_manage_doors(pc)
        else
          close_doors(pc, command)
        end
      end

      return
    elsif command.starts_with?("tele")
      if owner_clan?(pc)
        do_teleport(pc, command)
      end

      return
    end

    super
  end

  def show_chat_window(pc : L2PcInstance)
    pc.action_failed

    html = NpcHtmlMessage.new(l2id)

    if !owner_clan?(pc)
      html.set_file(pc, "data/html/doormen/#{template.id}-no.htm")
    else
      html.set_file(pc, "data/html/doormen/#{template.id}.htm")
    end

    html["%objectId%"] = l2id
    pc.send_packet(html)
  end

  private def open_doors(pc, cmd)
    st = cmd.from(10).split(", ")
    st.shift?
    st.each do |token|
      DoorData.get_door!(token.to_i).open_me
    end
  end

  private def close_doors(pc, cmd)
    st = cmd.from(11).split(", ")
    st.shift?
    st.each do |token|
      DoorData.get_door!(token.to_i).close_me
    end
  end

  private def cannot_manage_doors(pc)
    pc.action_failed

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, "data/html/doormen/#{template.id}-busy.htm")
    pc.send_packet(html)
  end

  private def do_teleport(pc, cmd)
    where = cmd.from(5).strip.to_i

    if list = TeleportLocationTable[where]?
      unless pc.looks_dead?
        pc.tele_to_location(list.x, list.y, list.z, false)
      end
    else
      warn { "No teleport destination with id #{where}." }
    end

    pc.action_failed
  end

  private def owner_clan?(pc : L2PcInstance) : Bool
    true
  end

  private def under_siege? : Bool
    false
  end
end
