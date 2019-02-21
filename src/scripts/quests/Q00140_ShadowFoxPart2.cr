class Quests::Q00140_ShadowFoxPart2 < Quest
  # NPCs
  private KLUCK = 30895
  private XENOVIA = 30912
  # Items
  private DARK_CRYSTAL = 10347
  private DARK_OXYDE = 10348
  private CRYPTOGRAM_OF_THE_GODDESS_SWORD = 10349
  # Monsters
  private MOBS = {
    20789 => 45,  # Crokian
    20790 => 58,  # Dailaon
    20791 => 100, # Crokian Warrior
    20792 => 92   # Farhite
  }
  # Misc
  private MIN_LEVEL = 37
  private MAX_REWARD_LEVEL = 42
  private CHANCE = 8
  private CRYSTAL_COUNT = 5
  private OXYDE_COUNT = 2

  def initialize
    super(140, self.class.simple_name, "Shadow Fox - 2")

    add_start_npc(KLUCK)
    add_talk_id(KLUCK, XENOVIA)
    add_kill_id(MOBS.keys)
    register_quest_items(DARK_CRYSTAL, DARK_OXYDE, CRYPTOGRAM_OF_THE_GODDESS_SWORD)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    htmltext = event
    case event
    when "30895-05.html", "30895-06.html", "30912-03.html", "30912-04.html",
          "30912-05.html", "30912-08.html", "30895-10.html"
      # do nothing
    when "30895-03.htm"
      st.start_quest
    when "30895-07.html"
      st.set_cond(2, true)
    when "30912-06.html"
      st.set("talk", "1")
    when "30912-09.html"
      st.unset("talk")
      st.set_cond(3, true)
    when "30912-14.html"
      if Rnd.rand(10) < CHANCE
        if st.get_quest_items_count(DARK_OXYDE) < OXYDE_COUNT
          st.give_items(DARK_OXYDE, 1)
          st.take_items(DARK_CRYSTAL, 5)
          return "30912-12.html"
        end
        st.give_items(CRYPTOGRAM_OF_THE_GODDESS_SWORD, 1)
        st.take_items(DARK_CRYSTAL, -1)
        st.take_items(DARK_OXYDE, -1)
        st.set_cond(4, true)
        return "30912-13.html"
      end
      st.take_items(DARK_CRYSTAL, 5)
    when "30895-11.html"
      st.give_adena(18775, true)
      if player.level <= MAX_REWARD_LEVEL
        st.add_exp_and_sp(30000, 2000)
      end
      st.exit_quest(false, true)
    else
      htmltext = nil
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    unless member = get_random_party_member(player, 3)
      return super
    end

    st = get_quest_state(member, false).not_nil!

    if Rnd.rand(100) < MOBS[npc.id]
      st.give_items(DARK_CRYSTAL, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case npc.id
    when KLUCK
      case st.state
      when State::CREATED
        if player.level >= MIN_LEVEL
          if player.quest_completed?(Q00139_ShadowFoxPart1.simple_name)
            htmltext = "30895-01.htm"
          else
            htmltext = "30895-00.htm"
          end
        else
          htmltext = "30895-02.htm"
        end
      when State::STARTED
        case st.cond
        when 1
          htmltext = "30895-04.html"
        when 2, 3
          htmltext = "30895-08.html"
        when 4
          if st.set?("talk")
            htmltext = "30895-10.html"
          else
            st.take_items(CRYPTOGRAM_OF_THE_GODDESS_SWORD, -1)
            st.set("talk", "1")
            htmltext = "30895-09.html"
          end
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when XENOVIA
      if st.started?
        case st.cond
        when 1
          htmltext = "30912-01.html"
        when 2
          htmltext = st.set?("talk") ? "30912-07.html" : "30912-02.html"
        when 3
          if st.get_quest_items_count(DARK_CRYSTAL) >= CRYSTAL_COUNT
            htmltext = "30912-11.html"
          else
            htmltext = "30912-10.html"
          end
        when 4
          htmltext = "30912-15.html"
        end
      end
    end


    htmltext || get_no_quest_msg(player)
  end
end
