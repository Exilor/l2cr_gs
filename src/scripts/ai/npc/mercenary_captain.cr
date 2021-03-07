class Scripts::MercenaryCaptain < AbstractNpcAI
  # NPCs
  private NPCS = {
    36481 => 13757, # Mercenary Captain (Gludio)
    36482 => 13758, # Mercenary Captain (Dion)
    36483 => 13759, # Mercenary Captain (Giran)
    36484 => 13760, # Mercenary Captain (Oren)
    36485 => 13761, # Mercenary Captain (Aden)
    36486 => 13762, # Mercenary Captain (Innadril)
    36487 => 13763, # Mercenary Captain (Goddard)
    36488 => 13764, # Mercenary Captain (Rune)
    36489 => 13765  # Mercenary Captain (Schuttgart)
  }
  # Items
  private STRIDER_WIND = 4422
  private STRIDER_STAR = 4423
  private STRIDER_TWILIGHT = 4424
  private GUARDIAN_STRIDER = 14819
  private ELITE_MERCENARY_CERTIFICATE = 13767
  private TOP_ELITE_MERCENARY_CERTIFICATE = 13768
  # Misc
  private DELAY = 3600000 # 1 hour
  private MIN_LEVEL = 40
  private CLASS_LEVEL = 2

  def initialize
    super(self.class.simple_name, "ai/npc")

    NPCS.each_key do |id|
      add_start_npc(id)
      add_first_talk_id(id)
      add_talk_id(id)
    end

    TerritoryWarManager.territories.each do |terr|
      terr.spawn_list.each do |sp|
        if NPCS.has_key?(sp.id)
          start_quest_timer("say", DELAY, sp.npc, nil, true)
        end
      end
    end
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    if pc
      st = event.split

      case st.shift
      when "36481-02.html"
        htmltext = event
      when "36481-03.html"
        html = NpcHtmlMessage.new(npc.l2id)
        html.html = get_htm(pc, "36481-03.html")
        html["%strider%"] = TerritoryWarManager.min_tw_badge_for_striders
        html["%gstrider%"] = TerritoryWarManager.min_tw_badge_for_big_strider
        pc.send_packet(html)
      when "territory"
        pc.send_packet(ExShowDominionRegistry.new(npc.castle.residence_id, pc))
      when "strider"
        type = st.shift

        if type == "3"
          price = TerritoryWarManager.min_tw_badge_for_big_strider
        else
          price = TerritoryWarManager.min_tw_badge_for_striders
        end
        badge_id = NPCS[npc.id]
        if get_quest_items_count(pc, badge_id) < price
          return "36481-07.html"
        end

        case type
        when "0"
          strider_id = STRIDER_WIND
        when "1"
          strider_id = STRIDER_STAR
        when "2"
          strider_id = STRIDER_TWILIGHT
        when "3"
          strider_id = GUARDIAN_STRIDER
        else
          warn { "Unknown strider type #{type}." }
          return
        end

        take_items(pc, badge_id, price)
        give_items(pc, strider_id, 1)
        htmltext = "36481-09.html"
      when "elite"
        if !has_quest_items?(pc, ELITE_MERCENARY_CERTIFICATE)
          htmltext = "36481-10.html"
        else
          list_id = 676 + npc.castle.residence_id
          MultisellData.separate_and_send(list_id, pc, npc, false)
        end
      when "top-elite"
        if !has_quest_items?(pc, TOP_ELITE_MERCENARY_CERTIFICATE)
          htmltext = "36481-10.html"
        else
          list_id = 685 + npc.castle.residence_id
          MultisellData.separate_and_send(list_id, pc, npc, false)
        end
      end

    elsif event.casecmp?("say") && !npc.decayed?
      if TerritoryWarManager.tw_in_progress?
        broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::CHARGE_CHARGE_CHARGE)
      elsif Rnd.bool
        broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::COURAGE_AMBITION_PASSION_MERCENARIES_WHO_WANT_TO_REALIZE_THEIR_DREAM_OF_FIGHTING_IN_THE_TERRITORY_WAR_COME_TO_ME_FORTUNE_AND_GLORY_ARE_WAITING_FOR_YOU)
      else
        broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::DO_YOU_WISH_TO_FIGHT_ARE_YOU_AFRAID_NO_MATTER_HOW_HARD_YOU_TRY_YOU_HAVE_NOWHERE_TO_RUN_BUT_IF_YOU_FACE_IT_HEAD_ON_OUR_MERCENARY_TROOP_WILL_HELP_YOU_OUT)
      end
    end

    htmltext
  end

  def on_first_talk(npc, pc)
    if pc.level < MIN_LEVEL || pc.class_id.level < CLASS_LEVEL
      "36481-08.html"
    elsif npc.my_lord?(pc)
      if npc.castle.siege.in_progress? || TerritoryWarManager.tw_in_progress?
        "36481-05.html"
      else
        "36481-04.html"
      end
    else
      if npc.castle.siege.in_progress? || TerritoryWarManager.tw_in_progress?
        "36481-06.html"
      else
        "#{npc.id}-01.html"
      end
    end
  end
end
