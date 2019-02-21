class Quests::Q00139_ShadowFoxPart1 < Quest
  # NPC
  private MIA = 30896
  # Monsters
  private MOBS = {
    20784, # Tasaba Lizardman
    20785, # Tasaba Lizardman Shaman
    21639, # Tasaba Lizardman
    21640  # Tasaba Lizardman Shaman
  }
  # Items
  private FRAGMENT = 10345
  private CHEST = 10346
  # Misc
  private MIN_LEVEL = 37
  private MAX_REWARD_LEVEL = 42
  private DROP_CHANCE = 68

  def initialize
    super(139, self.class.simple_name, "Shadow Fox - 1")

    add_start_npc(MIA)
    add_talk_id(MIA)
    add_kill_id(MOBS)
    register_quest_items(FRAGMENT, CHEST)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    htmltext = event
    case event
    when "30896-02.htm"
      if player.level < MIN_LEVEL
        htmltext = "30896-03.htm"
      end
    when "30896-04.htm"
      st.start_quest
    when "30896-11.html"
      st.set("talk", "1")
    when "30896-13.html"
      st.set_cond(2, true)
      st.unset("talk")
    when "30896-17.html"
      if Rnd.rand(20) < 3
        st.take_items(FRAGMENT, 10)
        st.take_items(CHEST, 1)
        return "30896-16.html"
      end
      st.take_items(FRAGMENT, -1)
      st.take_items(CHEST, -1)
      st.set("talk", "1")
    when "30896-19.html"
      st.give_adena(14050, true)
      if player.level <= MAX_REWARD_LEVEL
        st.add_exp_and_sp(30000, 2000)
      end
      st.exit_quest(false, true)
    when "30896-06.html", "30896-07.html", "30896-08.html", "30896-09.html",
         "30896-10.html", "30896-12.html", "30896-18.html"
    else
      htmltext = nil
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    unless member = get_random_party_member(player, 2)
      return super
    end

    st = get_quest_state(member, false).not_nil!

    if !st.set?("talk") && Rnd.rand(100) < DROP_CHANCE
      item_id = Rnd.rand(11) == 0 ? CHEST : FRAGMENT
      st.give_items(item_id, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      if player.quest_completed?(Q00138_TempleChampionPart2.simple_name)
        htmltext = "30896-01.htm"
      else
        htmltext = "30896-00.html"
      end
    when State::STARTED
      case st.cond
      when 1
        if st.set?("talk")
          htmltext =  "30896-11.html"
        else
          htmltext =  "30896-05.html"
        end
      when 2
        if st.set?("talk")
          htmltext = "30896-18.html"
        else
          if st.get_quest_items_count(FRAGMENT) >= 10 && st.get_quest_items_count(CHEST) >= 1
            htmltext = "30896-15.html"
          else
            htmltext = "30896-14.html"
          end
        end
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    end

    htmltext || get_no_quest_msg(player)
  end
end
