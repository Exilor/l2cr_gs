class L2PetManagerInstance < L2MerchantInstance
  def instance_type
    InstanceType::L2PetManagerInstance
  end

  def get_html_path(npc_id, val)
    pom = val == 0 ? npc_id : "#{npc_id}-#{val}"
    "data/html/petmanager/#{pom}.htm"
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

  # TODO: Evolve
end
