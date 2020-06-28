class Scripts::Q00326_VanquishRemnants < Quest
  # NPC
  private LEOPOLD = 30435
  # Items
  private RED_CROSS_BADGE = 1359
  private BLUE_CROSS_BADGE = 1360
  private BLACK_CROSS_BADGE = 1361
  private BLACK_LION_MARK = 1369
  # Monsters
  private MONSTERS = {
    20053 => {61, RED_CROSS_BADGE},   # Ol Mahum Patrol
    20058 => {61, RED_CROSS_BADGE},   # Ol Mahum Guard
    20061 => {57, BLUE_CROSS_BADGE},  # Ol Mahum Remnants
    20063 => {63, BLUE_CROSS_BADGE},  # Ol Mahum Shooter
    20066 => {59, BLACK_CROSS_BADGE}, # Ol Mahum Captain
    20436 => {55, BLUE_CROSS_BADGE},  # Ol Mahum Supplier
    20437 => {59, RED_CROSS_BADGE},   # Ol Mahum Recruit
    20438 => {60, BLACK_CROSS_BADGE}, # Ol Mahum General
    20439 => {62, BLUE_CROSS_BADGE}   # Ol Mahum Officer
  }

  # Misc
  private MIN_LVL = 21

  def initialize
    super(326, self.class.simple_name, "Vanquish Remnants")

    add_start_npc(LEOPOLD)
    add_talk_id(LEOPOLD)
    add_kill_id(MONSTERS.keys)
    register_quest_items(RED_CROSS_BADGE, BLUE_CROSS_BADGE, BLACK_CROSS_BADGE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if st = get_quest_state(pc, false)
      case event
      when "30435-03.htm"
        st.start_quest
        html = event
      when "30435-07.html"
        st.exit_quest(true, true)
        html = event
      when "30435-08.html"
        html = event
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.started? && Rnd.rand(100) < MONSTERS[npc.id][0]
      st.give_items(MONSTERS[npc.id][1], 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "30435-02.htm" : "30435-01.htm"
    when State::STARTED
      red_badges = st.get_quest_items_count(RED_CROSS_BADGE)
      blue_badges = st.get_quest_items_count(BLUE_CROSS_BADGE)
      black_badges = st.get_quest_items_count(BLACK_CROSS_BADGE)
      sum = red_badges + blue_badges + black_badges
      if sum > 0
        if sum >= 100 && !st.has_quest_items?(BLACK_LION_MARK)
          st.give_items(BLACK_LION_MARK, 1)
        end
        badges = (red_badges * 46) + (blue_badges * 52) + (black_badges * 58)
        amount = badges + (sum >= 10 ? 4320 : 0)
        st.give_adena(amount, true)
        take_items(pc, -1, {RED_CROSS_BADGE, BLUE_CROSS_BADGE, BLACK_CROSS_BADGE})
        if sum >= 100
          if st.has_quest_items?(BLACK_LION_MARK)
            html = "30435-09.html"
          else
            html = "30435-06.html"
          end
        else
          html = "30435-05.html"
        end
      else
        html = "30435-04.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
