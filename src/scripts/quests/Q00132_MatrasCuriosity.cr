class Quests::Q00132_MatrasCuriosity < Quest
  # NPCs
  private MATRAS = 32245
  private DEMON_PRINCE = 25540
  private RANKU = 25542
  # Items
  private FIRE = 10521
  private WATER = 10522
  private EARTH = 10523
  private WIND = 10524
  private DARKNESS = 10525
  private DIVINITY = 10526
  private BLUEPRINT_RANKU = 9800
  private BLUEPRINT_PRINCE = 9801

  def initialize
    super(132, self.class.simple_name, "Matras' Curiosity")

    add_start_npc(MATRAS)
    add_talk_id(MATRAS)
    add_kill_id(RANKU, DEMON_PRINCE)
    register_quest_items(BLUEPRINT_RANKU, BLUEPRINT_PRINCE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    htmltext = event

    if event.casecmp?("32245-03.htm") && player.level >= 76 && !st.completed?
      if st.created?
        st.start_quest
        st.set("rewarded_prince", "1")
        st.set("rewarded_ranku", "1")
      else
        htmltext = "32245-03a.htm"
      end
    elsif event.casecmp?("32245-07.htm") && st.cond?(3) && !st.completed?
      st.give_adena(65884, true)
      st.add_exp_and_sp(50541, 5094)
      st.give_items(FIRE, 1)
      st.give_items(WATER, 1)
      st.give_items(EARTH, 1)
      st.give_items(WIND, 1)
      st.give_items(DARKNESS, 1)
      st.give_items(DIVINITY, 1)
      st.exit_quest(false, true)
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    case npc.id
    when DEMON_PRINCE
      if pl = get_random_party_member(player, "rewarded_prince", "1")
        st = get_quest_state(pl, false).not_nil!
        st.give_items(BLUEPRINT_PRINCE, 1)
        st.set("rewarded_prince", "2")

        if st.has_quest_items?(BLUEPRINT_RANKU)
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    when RANKU
      if pl = get_random_party_member(player, "rewarded_ranku", "1")
        st = get_quest_state(pl, false).not_nil!
        st.give_items(BLUEPRINT_RANKU, 1)
        st.set("rewarded_ranku", "2")

        if st.has_quest_items?(BLUEPRINT_PRINCE)
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    nil
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    if st.created?
      htmltext = player.level >= 76 ? "32245-01.htm" : "32245-02.htm"
    elsif st.completed?
      htmltext = get_already_completed_msg(player)
    elsif st.started?
      case st.cond
      when 1, 2
        if st.has_quest_items?(BLUEPRINT_RANKU) && st.has_quest_items?(BLUEPRINT_PRINCE)
          st.take_items(BLUEPRINT_RANKU, -1)
          st.take_items(BLUEPRINT_PRINCE, -1)
          st.set_cond(3, true)
          htmltext = "32245-05.htm"
        else
          htmltext = "32245-04.htm"
        end
      when 3
        htmltext = "32245-06.htm"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
