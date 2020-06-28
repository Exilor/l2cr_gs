class Scripts::Q00283_TheFewTheProudTheBrave < Quest
  # NPC
  private PERWAN = 32133
  # Item
  private CRIMSON_SPIDER_CLAW = 9747
  # Monster
  private CRIMSON_SPIDER = 22244
  # Misc
  private CLAW_PRICE = 45
  private BONUS = 2187
  private MIN_LVL = 15

  def initialize
    super(283, self.class.simple_name, "The Few, The Proud, The Brave")

    add_kill_id(CRIMSON_SPIDER)
    add_start_npc(PERWAN)
    add_talk_id(PERWAN)
    register_quest_items(CRIMSON_SPIDER_CLAW)
  end

  def on_adv_event(event, npc, oc)
    return unless oc
    return unless st = get_quest_state(oc, false)

    case event
    when "32133-03.htm"
      st.start_quest
      html = event
    when "32133-06.html"
      html = event
    when "32133-08.html"
      if st.has_quest_items?(CRIMSON_SPIDER_CLAW)
        claws = st.get_quest_items_count(CRIMSON_SPIDER_CLAW)
        st.give_adena((claws * CLAW_PRICE) + (claws >= 10 ? BONUS : 0), true)
        st.take_items(CRIMSON_SPIDER_CLAW, -1)
        Q00261_CollectorsDream.give_newbie_reward(oc)
        html = event
      else
        html = "32133-07.html"
      end
    when "32133-09.html"
      st.exit_quest(true, true)
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if st = get_random_party_member_state(killer, -1, 3, npc)
      st.give_item_randomly(npc, CRIMSON_SPIDER_CLAW, 1, 0, 0.6, true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    html = get_no_quest_msg(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "32133-01.htm" : "32133-02.htm"
    when State::STARTED
      if st.has_quest_items?(CRIMSON_SPIDER_CLAW)
        html = "32133-04.html"
      else
        html = "32133-05.html"
      end
    end


    html
  end
end
