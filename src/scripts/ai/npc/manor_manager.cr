class Scripts::ManorManager < AbstractNpcAI
  NPC = {
    35644,
    35645,
    35319,
    35366,
    36456,
    35512,
    35558,
    35229,
    35230,
    35231,
    35277,
    35103,
    35145,
    35187
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPC)
    add_first_talk_id(NPC)
    add_talk_id(NPC)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "manager-help-01.htm", "manager-help-02.htm", "manager-help-03.htm"
      event
    end
  end

  def on_first_talk(npc, pc)
    if Config.allow_manor
      castle_id = npc.template.parameters.get_i32("manor_id", -1)
      if !pc.override_castle_conditions? && pc.clan_leader? && castle_id == pc.clan.castle_id
        "manager-lord.htm"
      else
        "manager.htm"
      end
    else
      get_htm(pc, "data/html/npcdefault.htm")
    end
  end

  @[Register(event: ON_NPC_MANOR_BYPASS, register: NPC, id: Scripts::ManorManager::NPC)]
  def on_npc_manor_bypass(evt : OnNpcManorBypass)
    pc = evt.active_char

    if CastleManorManager.under_maintenance?
      pc.send_packet(SystemMessageId::THE_MANOR_SYSTEM_IS_CURRENTLY_UNDER_MAINTENANCE)
      return
    end

    npc = evt.target
    template_id = npc.template.parameters.get_i32("manor_id", -1)
    castle_id = evt.manor_id == -1 ? template_id : evt.manor_id

    case evt.request
    when 1 # Seed purchase
      if template_id != castle_id
        sm = SystemMessage.here_you_can_buy_only_seeds_of_s1_manor
        sm.add_castle_id(template_id)
        pc.send_packet(sm)
        return
      end
      pc.send_packet(BuyListSeed.new(pc.adena, castle_id))
    when 2 # Crop sales
      pc.send_packet(ExShowSellCropList.new(pc.inventory, castle_id))
    when 3 # Seed info
      pc.send_packet(ExShowSeedInfo.new(castle_id, evt.next_period?, false))
    when 4 # Crop info
      pc.send_packet(ExShowCropInfo.new(castle_id, evt.next_period?, false))
    when 5 # Basic info
      pc.send_packet(ExShowManorDefaultInfo.new(false))
    when 6 # Buy harvester
      npc.as(L2MerchantInstance).show_buy_window(pc, 300000 + npc.id)
    when 9 # Edit sales (Crop sales)
      pc.send_packet(ExShowProcureCropDetail.new(evt.manor_id))
    else
      warn "Player #{pc.name} (#{pc.l2id}) sent unknown request id #{evt.request}."
    end
  end
end
