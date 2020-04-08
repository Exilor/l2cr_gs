class L2PetManagerInstance < L2MerchantInstance
  def instance_type : InstanceType
    InstanceType::L2PetManagerInstance
  end

  def get_html_path(npc_id, val)
    if val == 0
      "data/html/petmanager/#{npc_id}.htm"
    else
      "data/html/petmanager/#{npc_id}-#{val}.htm"
    end
  end

  def show_chat_window(pc : L2PcInstance)
    if id == 36478 && pc.has_summon?
      file_name = "data/html/petmanager/restore-unsummonpet.htm"
    else
      file_name = "data/html/petmanager/#{id}.htm"
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)
    if Config.allow_rentpet && Config.list_pet_rent_npc.includes?(id)
      html["_Quest"] = "_RentPet\">Rent Pet</a><br><a action=\"bypass -h npc_%objectId%_Quest"
    end

    html["%objectId%"] = l2id
    html["%npcname%"] = name

    pc.send_packet(html)
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    if command.starts_with?("exchange")
      case val = command.split[1].to_i
      when 1
        exchange(pc, 7585, 6650)
      when 2
        exchange(pc, 7583, 6648)
      when 3
        exchange(pc, 7584, 6649)
      else
        # automatically added
      end

    elsif command.starts_with?("evolve")
      ok = false

      case val = command.split[1].to_i
      when 1
        ok = Evolve.do_evolve(pc, self, 2375, 9882, 55)
      when 2
        ok = Evolve.do_evolve(pc, self, 9882, 10426, 70)
      when 3
        ok = Evolve.do_evolve(pc, self, 6648, 10311, 55)
      when 4
        ok = Evolve.do_evolve(pc, self, 6650, 10313, 55)
      when 5
        ok = Evolve.do_evolve(pc, self, 6649, 10312, 55)
      else
        # automatically added
      end


      unless ok
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, "data/html/petmanager/evolve_no.htm")
        pc.send_packet(html)
      end
    elsif command.starts_with?("restore")
      ok = false

      case val = command.split[1].to_i
      when 1
        ok = Evolve.do_restore(pc, self, 10307, 9882, 55)
      when 2
        ok = Evolve.do_restore(pc, self, 10611, 10426, 70)
      when 3
        ok = Evolve.do_restore(pc, self, 10308, 4422, 55)
      when 4
        ok = Evolve.do_restore(pc, self, 10309, 4423, 55)
      when 5
        ok = Evolve.do_restore(pc, self, 10310, 4424, 55)
      else
        # automatically added
      end


      unless ok
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, "data/html/petmanager/restore_no.htm")
        pc.send_packet(html)
      end
    else
      super
    end
  end

  def exchange(pc : L2PcInstance, item_id_take : Int32, item_id_give : Int32)
    html = NpcHtmlMessage.new(l2id)

    if pc.destroy_item_by_item_id("Consume", item_id_take, 1, self, true)
      pc.add_item("", item_id_give, 1, self, true)
      html.set_file(pc, "data/html/petmanager/#{id}.htm")
    else
      html.set_file(pc, "data/html/petmanager/exchange_no.htm")
    end

    pc.send_packet(html)
  end
end