class Scripts::Q00005_MinersFavor < Quest
  # NPCs
  private BOLTER = 30554
  private SHARI  = 30517
  private GARITA = 30518
  private REED   = 30520
  private BRUNON = 30526
  # Items
  private BOLTERS_LIST = 1547
  private MINING_BOOTS = 1548
  private MINERS_PICK = 1549
  private BOOMBOOM_POWDER = 1550
  private REDSTONE_BEER = 1551
  private BOLTERS_SMELLY_SOCKS = 1552
  private NECKLACE = 906
  # Misc
  private MIN_LEVEL = 2

  def initialize
    super(5, self.class.simple_name, "Miner's Favor")

    add_start_npc(BOLTER)
    add_talk_id(BOLTER, SHARI, GARITA, REED, BRUNON)
    register_quest_items(
      BOLTERS_LIST,  MINING_BOOTS, MINERS_PICK, BOOMBOOM_POWDER, REDSTONE_BEER,
      BOLTERS_SMELLY_SOCKS
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    html = event

    case event
    when "30554-03.htm"
      st.start_quest
      give_items(pc, BOLTERS_LIST, 1)
      give_items(pc, BOLTERS_SMELLY_SOCKS, 1)
    when "30526-02.html"
      unless has_quest_items?(pc, BOLTERS_SMELLY_SOCKS)
        return "30526-04.html"
      end

      take_items(pc, BOLTERS_SMELLY_SOCKS, -1)
      give_items(pc, MINERS_PICK, 1)
      check_progress(pc, st)
    when "30554-05.html"
      return
    end

    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when BOLTER
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30554-02.htm" : "30554-01.html"
      when State::STARTED
        if st.cond?(1)
          html = "30554-04.html"
        else
          give_adena(pc, 2466, true)
          add_exp_and_sp(pc, 5672, 446)
          give_items(pc, NECKLACE, 1)
          st.exit_quest false, true
          msg = NpcString::DELIVERY_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE
          show_on_screen_msg(pc, msg, 2, 5000)
          html = "30554-06.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when BRUNON
      if st.started?
        if has_quest_items?(pc, MINERS_PICK)
          html = "30526-03.html"
        else
          html = "30526-01.html"
        end
      end
    when REED
      html = give_item(pc, st, npc.id, REDSTONE_BEER)
    when SHARI
      html = give_item(pc, st, npc.id, BOOMBOOM_POWDER)
    when GARITA
      html = give_item(pc, st, npc.id, MINING_BOOTS)
    end

    html || get_no_quest_msg(pc)
  end

  private def check_progress(pc, st)
    if has_quest_items?(pc, BOLTERS_LIST, MINING_BOOTS, MINERS_PICK, BOOMBOOM_POWDER, REDSTONE_BEER)
      st.set_cond(2, true)
    end
  end

  private def give_item(pc, st, npc_id, item_id)
    if !st.started?
      get_no_quest_msg(pc)
    elsif has_quest_items?(pc, item_id)
      "#{npc_id}-02.html"
    else
      give_items(pc, item_id, 1)
      play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
      check_progress(pc, st)
      "#{npc_id}-01.html"
    end
  end
end
