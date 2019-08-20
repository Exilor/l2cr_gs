class L2FortDoormenInstance < L2DoormenInstance
  def instance_type : InstanceType
    InstanceType::L2FortDoormenInstance
  end

  def show_chat_window(pc : L2PcInstance)
    pc.action_failed

    html = NpcHtmlMessage.new(l2id)

    if !owner_clan?(pc)
      html.set_file(pc, "data/html/doormen/#{template.id}-no.htm")
    elsif under_siege?
      html.set_file(pc, "data/html/doormen/#{template.id}-busy.htm")
    else
      html.set_file(pc, "data/html/doormen/#{template.id}.htm")
    end

    html["%objectId%"] = l2id
    pc.send_packet(html)
  end

  private def open_doors(pc : L2PcInstance, command : String)
    st = command.from(10).split(", ")
    st.shift?

    until st.empty?
      fort.open_door(pc, st.shift.to_i)
    end
  end

  private def close_doors(pc : L2PcInstance, command : String)
    st = command.from(11).split(", ")
    st.shift?

    until st.empty?
      fort.close_door(pc, st.shift.to_i)
    end
  end

  private def owner_clan?(pc : L2PcInstance) : Bool
    return false unless clan = pc.clan?
    unless fort = fort?
      warn "This npc has no fort."
      return false
    end

    unless owner = fort.owner_clan?
      debug "This npc's fort (#{fort}) has no owner."
      return false
    end

    pc.clan_id == owner.id
  end

  private def under_siege? : Bool
    fort.zone.active?
  end
end
