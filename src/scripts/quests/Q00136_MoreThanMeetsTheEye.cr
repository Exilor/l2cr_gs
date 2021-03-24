class Scripts::Q00136_MoreThanMeetsTheEye < Quest
  # NPCs
  private HARDIN = 30832
  private ERRICKIN = 30701
  private CLAYTON = 30464

  # Monsters
  private GLASS_JAGUAR = 20250
  private GHOST1 = 20636
  private GHOST2 = 20637
  private GHOST3 = 20638
  private MIRROR = 20639

  # Items
  private ECTOPLASM = 9787
  private STABILIZED_ECTOPLASM = 9786
  private ORDER = 9788
  private GLASS_JAGUAR_CRYSTAL = 9789
  private BOOK_OF_SEAL = 9790
  private TRANSFORM_BOOK = 9648

  # Misc
  private MIN_LEVEL = 50
  private ECTOPLASM_COUNT = 35i64
  private CRYSTAL_COUNT = 5i64
  private CHANCES = {0, 40, 90, 290}

  def initialize
    super(136, self.class.simple_name, "More Than Meets the Eye")

    add_start_npc(HARDIN)
    add_talk_id(HARDIN, ERRICKIN, CLAYTON)
    add_kill_id(GHOST1, GHOST2, GHOST3, GLASS_JAGUAR, MIRROR)
    register_quest_items(
      ECTOPLASM, STABILIZED_ECTOPLASM, ORDER, GLASS_JAGUAR_CRYSTAL,
      BOOK_OF_SEAL
    )
  end

  private def give_item(st, item_id, count, max_count, cond)
    st.give_items(item_id, count.to_i64)
    if st.get_quest_items_count(item_id) >= max_count
      st.set_cond(cond, true)
    else
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    html = event
    case event
    when "30832-05.html", "30832-06.html", "30832-12.html", "30832-13.html",
      "30832-18.html", "30832-03.htm"
      st.start_quest
    when "30832-07.html"
      st.set_cond(2, true)
    when "30832-11.html"
      st.set("talked", "2")
    when "30832-14.html"
      st.unset("talked")
      st.give_items(ORDER, 1)
      st.set_cond(6, true)
    when "30832-17.html"
      st.set("talked", "2")
    when "30832-19.html"
      st.give_items(TRANSFORM_BOOK, 1)
      st.give_adena(67_550, true)
      st.exit_quest(false, true)
    when "30701-03.html"
      st.set_cond(3, true)
    when "30464-03.html"
      st.take_items(ORDER, -1)
      st.set_cond(7, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    return super unless st = get_quest_state(killer, false)

    npc_id = npc.id
    if npc_id != GLASS_JAGUAR && st.cond?(3)
      if npc_id == MIRROR && st.get_quest_items_count(ECTOPLASM) &+ 2 < ECTOPLASM_COUNT
        count = 2
      else
        count = 1
      end

      index = npc_id - GHOST1

      if Rnd.rand(1000) < CHANCES[index] && st.get_quest_items_count(ECTOPLASM) &+ count < ECTOPLASM_COUNT
        st.give_items(ECTOPLASM, 1)
      end
      give_item(st, ECTOPLASM, count, ECTOPLASM_COUNT, 4)
    elsif npc_id == GLASS_JAGUAR && st.cond?(7)
      give_item(st, GLASS_JAGUAR_CRYSTAL, 1, CRYSTAL_COUNT, 8)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    html = get_no_quest_msg(pc)

    case npc.id
    when HARDIN
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30832-01.htm" : "30832-02.htm"
      when State::STARTED
        case st.cond
        when 1
          html = "30832-04.html"
        when 2..4
          html = "30832-08.html"
        when 5
          if st.get_int("talked") == 1
            html = "30832-10.html"
          elsif st.get_int("talked") == 2
            html = "30832-12.html"
          elsif st.has_quest_items?(STABILIZED_ECTOPLASM)
            st.take_items(STABILIZED_ECTOPLASM, -1)
            st.set("talked", "1")
            html = "30832-09.html"
          else
            html = "30832-08.html"
          end
        when 6..8
          html = "30832-15.html"
        when 9
          if st.get_int("talked") == 1
            st.set("talked", "2")
            html = "30832-17.html"
          elsif st.get_int("talked") == 2
            html = "30832-18.html"
          else
            st.take_items(BOOK_OF_SEAL, -1)
            st.set("talked", "1")
            html = "30832-16.html"
          end
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when ERRICKIN
      if st.started?
        case st.cond
        when 1
          html = "30701-01.html"
        when 2
          html = "30701-02.html"
        when 3
          html = "30701-04.html"
        when 4
          if st.get_quest_items_count(ECTOPLASM) < ECTOPLASM_COUNT
            st.give_items(STABILIZED_ECTOPLASM, 1)
            st.set_cond(5, true)
            html = "30701-06.html"
          else
            st.take_items(ECTOPLASM, -1)
            html = "30701-05.html"
          end
        else
          html = "30701-07.html"
        end
      end
    when CLAYTON
      if st.started?
        case st.cond
        when 1..5
          html = "30464-01.html"
        when 6
          html = "30464-02.html"
        when 7
          html = "30464-04.html"
        when 8
          st.give_items(BOOK_OF_SEAL, 1)
          st.take_items(GLASS_JAGUAR_CRYSTAL, -1)
          st.set_cond(9, true)
          html = "30464-05.html"
        else
          html = "30464-06.html"
        end
      end
    end

    html
  end
end
