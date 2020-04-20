class Scripts::Q00004_LongLiveThePaagrioLord < Quest
  # NPCs
  private KUNAI = 30559
  private USKA = 30560
  private GROOKIN = 30562
  private VARKEES = 30566
  private NAKUSIN = 30578
  private HESTUI = 30585
  private URUTU = 30587
  # Items
  private CLUB = 4
  private HONEY_KHANDAR = 1541
  private BEAR_FUR_CLOAK = 1542
  private BLOODY_AXE = 1543
  private ANCESTOR_SKULL = 1544
  private SPIDER_DUST = 1545
  private DEEP_SEA_ORB = 1546
  # Misc
  private MIN_LEVEL = 2

  def initialize
    super(4, self.class.simple_name, "Long Live the Pa'agrio Lord")

    add_start_npc(NAKUSIN)
    add_talk_id(NAKUSIN, VARKEES, URUTU, HESTUI, KUNAI, USKA, GROOKIN)
    register_quest_items(
      HONEY_KHANDAR, BEAR_FUR_CLOAK, BLOODY_AXE, ANCESTOR_SKULL, SPIDER_DUST,
      DEEP_SEA_ORB
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30578-03.htm"
      st.start_quest
      event
    when "30578-05.html"
      event
    else
      # [automatically added else]
    end
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when NAKUSIN
      case st.state
      when State::CREATED
        if !pc.race.orc?
          html = "30578-00.htm"
        else
          if pc.level >= MIN_LEVEL
            html = "30578-02.htm"
          else
            html = "30578-01.htm"
          end
        end
      when State::STARTED
        if st.cond? 1
          html = "30578-04.html"
        else
          give_items(pc, CLUB, 1)
          msg = NpcString::DELIVERY_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE
          show_on_screen_msg(pc, msg, 2, 5000)
          add_exp_and_sp(pc, 4254, 335)
          give_adena(pc, 1850, true)
          st.exit_quest(false, true)
          html = "30578-06.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end
    when VARKEES
      html = give_item(pc, st, npc.id, HONEY_KHANDAR)
    when URUTU
      html = give_item(pc, st, npc.id, DEEP_SEA_ORB)
    when HESTUI
      html = give_item(pc, st, npc.id, BEAR_FUR_CLOAK)
    when KUNAI
      html = give_item(pc, st, npc.id, SPIDER_DUST)
    when USKA
      html = give_item(pc, st, npc.id, ANCESTOR_SKULL)
    when GROOKIN
      html = give_item(pc, st, npc.id, BLOODY_AXE)
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end

  private def give_item(pc, st, npc_id, item_id)
    if !st.started?
      return get_no_quest_msg(pc)
    elsif has_quest_items?(pc, item_id)
      return "#{npc_id}-02.html"
    end

    give_items(pc, item_id, 1)
    play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)

    if has_quest_items?(pc, registered_item_ids)
      st.set_cond(2, true)
    end

    "#{npc_id}-01.html"
  end
end
