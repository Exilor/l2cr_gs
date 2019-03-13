class Quests::Q00239_WontYouJoinUs < Quest
  # NPC
  private ATHENIA = 32643
  # Mobs
  private WASTE_LANDFILL_MACHINE = 18805
  private SUPPRESSOR = 22656
  private EXTERMINATOR = 22657
  # Items
  private SUPPORT_CERTIFICATE = 14866
  private DESTROYED_MACHINE_PIECE = 14869
  private ENCHANTED_GOLEM_FRAGMENT = 14870
  # Misc
  private ENCHANTED_GOLEM_FRAGMENT_NEEDED = 20
  private DESTROYED_MACHINE_PIECE_NEEDED = 10
  private CHANCE_FOR_FRAGMENT = 80
  private MIN_LEVEL = 82

  def initialize
    super(239, self.class.simple_name, "Won't You Join Us?")

    add_start_npc(ATHENIA)
    add_talk_id(ATHENIA)
    add_kill_id(WASTE_LANDFILL_MACHINE, SUPPRESSOR, EXTERMINATOR)
    register_quest_items(DESTROYED_MACHINE_PIECE, ENCHANTED_GOLEM_FRAGMENT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    case event
    when "32643-02.htm"
      html = event
    when "32643-03.html"
      st.start_quest
      html = event
    when "32643-07.html"
      if st.cond?(2)
        st.set_cond(3, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == WASTE_LANDFILL_MACHINE
      if m = get_random_party_member(killer, 1)
        st = get_quest_state(m, false).not_nil!
        if st.get_quest_items_count(DESTROYED_MACHINE_PIECE) < DESTROYED_MACHINE_PIECE_NEEDED
          st.give_items(DESTROYED_MACHINE_PIECE, 1)
        end
        if st.get_quest_items_count(DESTROYED_MACHINE_PIECE) == DESTROYED_MACHINE_PIECE_NEEDED
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    else
      m = get_random_party_member(killer, 3)
      if m && rand(100) < CHANCE_FOR_FRAGMENT
        st = get_quest_state(m, false).not_nil!
        if st.get_quest_items_count(ENCHANTED_GOLEM_FRAGMENT) < ENCHANTED_GOLEM_FRAGMENT_NEEDED
          st.give_items(ENCHANTED_GOLEM_FRAGMENT, 1)
        end
        if st.get_quest_items_count(ENCHANTED_GOLEM_FRAGMENT) == ENCHANTED_GOLEM_FRAGMENT_NEEDED
          st.set_cond(4, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, talker)
    st = get_quest_state!(talker)
    case st.state
    when State::COMPLETED
      html = "32643-11.html"
    when State::CREATED
      if st.player.quest_completed?(Q00238_SuccessFailureOfBusiness.simple_name)
        html = "32643-12.html"
      elsif st.player.quest_completed?(Q00237_WindsOfChange.simple_name) && talker.level >= MIN_LEVEL && st.has_quest_items?(SUPPORT_CERTIFICATE)
        html = "32643-01.htm"
      else
        html = "32643-00.html"
      end
    when State::STARTED
      case st.cond
      when 1
        html = st.has_quest_items?(DESTROYED_MACHINE_PIECE) ? "32643-05.html" : "32643-04.html"
      when 2
        if st.get_quest_items_count(DESTROYED_MACHINE_PIECE) == DESTROYED_MACHINE_PIECE_NEEDED
          html = "32643-06.html"
          st.take_items(DESTROYED_MACHINE_PIECE, -1)
        end
      when 3
        html = st.has_quest_items?(ENCHANTED_GOLEM_FRAGMENT) ? "32643-08.html" : "32643-09.html"
      when 4
        if st.get_quest_items_count(ENCHANTED_GOLEM_FRAGMENT) == ENCHANTED_GOLEM_FRAGMENT_NEEDED
          html = "32643-10.html"
          st.give_adena(283346, true)
          st.take_items(SUPPORT_CERTIFICATE, 1)
          st.add_exp_and_sp(1319736, 103553)
          st.exit_quest(false, true)
        end
      end
    end

    html || get_no_quest_msg(talker)
  end
end
