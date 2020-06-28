class Scripts::Q00464_Oath < Quest
  private NPC = {
    # NPC id, EXP, SP, Adena
    {32596,      0,     0,      0},
    {30657,  15449, 17696,  42910},
    {30839, 189377, 21692,  52599},
    {30899, 249180, 28542,  69210},
    {31350, 249180, 28542,  69210},
    {30539,  19408, 47062, 169442},
    {30297,  24146, 58551, 210806},
    {31960,  15449, 17696,  42910},
    {31588,  15449, 17696,  42910}
  }

  # Items
  private STRONGBOX = 15537
  private BOOK = 15538
  private BOOK2 = 15539
  # Misc
  private MIN_LEVEL = 82

  # Monsters
  private MOBS = {
    22799 => 9,
    22794 => 6,
    22800 => 10,
    22796 => 9,
    22798 => 9,
    22795 => 8,
    22797 => 7,
    22789 => 5,
    22791 => 4,
    22790 => 5,
    22792 => 4,
    22793 => 5
  }

  def initialize
    super(464, self.class.simple_name, "Oath")

    NPC.each do |npc|
      add_talk_id(npc[0])
    end
    add_kill_id(MOBS.keys)
    add_item_talk_id(STRONGBOX)
    register_quest_items(BOOK, BOOK2)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "32596-04.html"
      unless st.has_quest_items?(BOOK)
        return get_no_quest_msg(pc)
      end

      cond = Rnd.rand(2..9)
      st.set("npc", NPC[cond - 1][0].to_s)
      st.set_cond(cond, true)
      st.take_items(BOOK, 1)
      st.give_items(BOOK2, 1)
      case cond
      when 2
        html = "32596-04.html"
      when 3
        html = "32596-04a.html"
      when 4
        html = "32596-04b.html"
      when 5
        html = "32596-04c.html"
      when 6
        html = "32596-04d.html"
      when 7
        html = "32596-04e.html"
      when 8
        html = "32596-04f.html"
      when 9
        html = "32596-04g.html"
      end

    when "end_quest"
      unless st.has_quest_items?(BOOK2)
        return get_no_quest_msg(pc)
      end

      i = st.cond - 1
      st.add_exp_and_sp(NPC[i][1], NPC[i][2])
      st.give_adena(NPC[i][3], true)
      st.exit_quest(QuestType::DAILY, true)
      html = "#{npc.id}-02.html"
    when "32596-02.html", "32596-03.html"
      # do nothing
    else
      html = nil
    end

    html
  end

  def on_item_talk(item, pc)
    st = get_quest_state!(pc)

    start_quest = false
    case st.state
    when State::CREATED
      start_quest = true
    when State::STARTED
      html = "strongbox-02.html"
    when State::COMPLETED
      if st.now_available?
        st.state = State::CREATED
        start_quest = true
      else
        html = "strongbox-03.html"
      end
    end


    if start_quest
      if pc.level >= MIN_LEVEL
        st.start_quest
        st.take_items(STRONGBOX, 1)
        st.give_items(BOOK, 1)
        html = "strongbox-01.htm"
      else
        html = "strongbox-00.htm"
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    if Rnd.rand(1000) < MOBS[npc.id]
      npc.drop_item(killer, STRONGBOX, 1)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.started?
      npc_id = npc.id
      if npc_id == NPC[0][0]
        case st.cond
        when 1
          html = "32596-01.html"
        when 2
          html = "32596-05.html"
        when 3
          html = "32596-05a.html"
        when 4
          html = "32596-05b.html"
        when 5
          html = "32596-05c.html"
        when 6
          html = "32596-05d.html"
        when 7
          html = "32596-05e.html"
        when 8
          html = "32596-05f.html"
        when 9
          html = "32596-05g.html"
        end

      elsif st.cond > 1 && st.get_int("npc") == npc_id
        html = "#{npc_id}-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
