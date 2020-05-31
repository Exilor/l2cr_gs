require "../../../util/evolve"

class L2ClanHallDoormenInstance < L2DoormenInstance
  private CH_WITH_EVOLVE = {36, 37, 38, 39, 40, 41, 51, 52, 53, 54, 55, 56, 57}

  @init = false
  @has_evolve = false
  @clan_hall : ClanHall?

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    if @has_evolve && command.starts_with?("evolve")
      if owner_clan?(pc)
        st = command.split
        if st.size < 2
          return
        end

        st.shift

        ok = false

        case st.shift.to_i
        when 1
          ok = Evolve.do_evolve(pc, self, 9882, 10307, 55)
        when 2
          ok = Evolve.do_evolve(pc, self, 4422, 10308, 55)
        when 3
          ok = Evolve.do_evolve(pc, self, 4423, 10309, 55)
        when 4
          ok = Evolve.do_evolve(pc, self, 4424, 10310, 55)
        when 5
          ok = Evolve.do_evolve(pc, self, 10426, 10611, 70)
        else
          # [automatically added else]
        end

        html = NpcHtmlMessage.new(l2id)
        if ok
          html.set_file(pc, "data/html/clanHallDoormen/evolve-ok.htm")
        else
          html.set_file(pc, "data/html/clanHallDoormen/evolve-no.htm")
        end
        pc.send_packet(html)

        return
      end
    end

    super
  end

  def show_chat_window(pc : L2PcInstance)
    pc.action_failed

    html = NpcHtmlMessage.new(l2id)

    if ch = clan_hall?
      owner = ClanTable.get_clan(ch.owner_id)

      if owner_clan?(pc)
        if @has_evolve
          html.set_file(pc, "data/html/clanHallDoormen/doormen2.htm")
          html["%clanname%"] = owner.not_nil!.name
        else
          html.set_file(pc, "data/html/clanHallDoormen/doormen1.htm")
          html["%clanname%"] = owner.not_nil!.name
        end
      else
        if owner && owner.leader?
          html.set_file(pc, "data/html/clanHallDoormen/doormen-no.htm")
          html["%leadername%"] = owner.leader_name
          html["%clanname%"] = owner.name
        else
          html.set_file(pc, "data/html/clanHallDoormen/emptyowner.htm")
          html["%hallname%"] = ch.name
        end
      end
    else
      return
    end

    html["%objectId%"] = l2id
    pc.send_packet(html)
  end

  private def open_doors(pc : L2PcInstance, command : String)
    clan_hall.open_close_doors(true)
    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, "data/html/clanHallDoormen/doormen-opened.htm")
    html["%objectId%"] = l2id
    pc.send_packet(html)
  end

  private def close_door(pc : L2PcInstance, command : String)
    clan_hall.open_close_doors(false)
    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, "data/html/clanHallDoormen/doormen-closed.htm")
    html["%objectId%"] = l2id
    pc.send_packet(html)
  end

  private def clan_hall? : ClanHall?
    unless @init
      sync do
        if ch = ClanHallManager.get_nearby_clan_hall(x, y, 500)
          @clan_hall = ch
          @has_evolve = CH_WITH_EVOLVE.bincludes?(ch.id)
        end
        @init = true
      end
    end

    @clan_hall
  end

  private def clan_hall : ClanHall
    unless ch = clan_hall?
      raise "No clan hall found"
    end

    ch
  end

  private def owner_clan?(pc : L2PcInstance) : Bool
    if pc.clan && (ch = clan_hall?)
      if pc.clan_id == ch.owner_id
        return true
      end
    end

    false
  end

  def instance_type : InstanceType
    InstanceType::L2ClanHallDoormenInstance
  end
end
