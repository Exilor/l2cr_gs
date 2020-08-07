class L2FortLogisticsInstance < L2MerchantInstance
  private SUPPLY_BOX_IDS = {
    35665,
    35697,
    35734,
    35766,
    35803,
    35834,
    35866,
    35903,
    35935,
    35973,
    36010,
    36042,
    36080,
    36117,
    36148,
    36180,
    36218,
    36256,
    36293,
    36325,
    36363
  }

  def instance_type : InstanceType
    InstanceType::L2FortLogisticsInstance
  end

  def get_html_path(npc_id, val)
    if val == 0
      "data/html/fortress/logistics.htm"
    else
      "data/html/fortress/logistics-#{val}.htm"
    end
  end

  def on_bypass_feedback(pc : L2PcInstance, cmd : String)
    last_npc = pc.last_folk_npc
    if last_npc.nil? || last_npc.l2id != l2id
      return
    end

    st = cmd.split
    actual_cmd = st.shift

    html = NpcHtmlMessage.new(l2id)

    if actual_cmd.casecmp?("rewards")
      if (clan = pc.clan) && my_lord?(pc)
        html.set_file(pc, "data/html/fortress/logistics-rewards.htm")
        html["%bloodoath%"] = clan.blood_oath_count
      else
        html.set_file(pc, "data/html/fortress/logistics-noprivs.htm")
      end

      html["%objectId%"] = l2id
      pc.send_packet(html)
    elsif actual_cmd.casecmp?("blood")
      if (clan = pc.clan) && my_lord?(pc)
        blood = clan.blood_oath_count
        if blood > 0
          pc.add_item("Quest", 9910, blood.to_i64, self, true)
          clan.reset_blood_oath_count
          html.set_file(pc, "data/html/fortress/logistics-blood.htm")
        else
          html.set_file(pc, "data/html/fortress/logistics-noblood.htm")
        end
      else
        html.set_file(pc, "data/html/fortress/logistics-noprivs.htm")
      end

      html["%objectId%"] = l2id
      pc.send_packet(html)
    elsif actual_cmd.casecmp?("supplylvl")
      if fort.fort_state == 2
        if pc.clan_leader?
          html.set_file(pc, "data/html/fortress/logistics-supplylvl.htm")
          html["%supplylvl%"] = fort.supply_lvl
        else
          html.set_file(pc, "data/html/fortress/logistics-noprivs.htm")
        end
      else
        html.set_file(pc, "data/html/fortress/logistics-1.htm") # L2J TODO: Missing HTML?
      end

      html["%objectId%"] = l2id
      pc.send_packet(html)
    elsif actual_cmd.casecmp?("supply")
      if my_lord?(pc)
        if fort.siege.in_progress?
          html.set_file(pc, "data/html/fortress/logistics-siege.htm")
        else
          level = fort.supply_lvl
          if level > 0
            box_template = NpcData[SUPPLY_BOX_IDS[level &- 1]]
            box = L2MonsterInstance.new(box_template)
            box.heal!
            box.heading = 0
            box.spawn_me(x - 23, y + 41, z)

            fort.supply_lvl = 0
            fort.save_fort_variables

            html.set_file(pc, "data/html/fortress/logistics-supply.htm")
          else
            html.set_file(pc, "data/html/fortress/logistics-nosupply.htm")
          end
        end
      else
        html.set_file(pc, "data/html/fortress/logistics-noprivs.htm")
      end

      html["%objectId%"] = l2id
      pc.send_packet(html)
    else
      super
    end
  end

  def show_chat_window(pc : L2PcInstance)
    show_message_window(pc, 0)
  end

  private def show_message_window(pc : L2PcInstance, val : Int32)
    pc.action_failed

    if val == 0
      file_name = "data/html/fortress/logistics.htm"
    else
      file_name = "data/html/fortress/logistics-#{val}.htm"
    end


    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    html["%npcId%"] = id

    html["%clanname%"] = fort.owner_clan?.try &.name || "NPC"

    pc.send_packet(html)
  end

  def has_random_animation? : Bool
    false
  end
end
