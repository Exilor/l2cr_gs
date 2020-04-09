class Scripts::Q00140_ShadowFoxPart2 < Quest
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
    register_quest_items(
      DARK_CRYSTAL, DARK_OXYDE, CRYPTOGRAM_OF_THE_GODDESS_SWORD
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
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
      if pc.level <= MAX_REWARD_LEVEL
        st.add_exp_and_sp(30000, 2000)
      end
      st.exit_quest(false, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 3)
      return super
    end

    st = get_quest_state(member, false).not_nil!

    if Rnd.rand(100) < MOBS[npc.id]
      st.give_items(DARK_CRYSTAL, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when KLUCK
      case st.state
      when State::CREATED
        if pc.level >= MIN_LEVEL
          if pc.quest_completed?(Q00139_ShadowFoxPart1.simple_name)
            html = "30895-01.htm"
          else
            html = "30895-00.htm"
          end
        else
          html = "30895-02.htm"
        end
      when State::STARTED
        case st.cond
        when 1
          html = "30895-04.html"
        when 2, 3
          html = "30895-08.html"
        when 4
          if st.set?("talk")
            html = "30895-10.html"
          else
            st.take_items(CRYPTOGRAM_OF_THE_GODDESS_SWORD, -1)
            st.set("talk", "1")
            html = "30895-09.html"
          end
        else
          # [automatically added else]
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when XENOVIA
      if st.started?
        case st.cond
        when 1
          html = "30912-01.html"
        when 2
          html = st.set?("talk") ? "30912-07.html" : "30912-02.html"
        when 3
          if st.get_quest_items_count(DARK_CRYSTAL) >= CRYSTAL_COUNT
            html = "30912-11.html"
          else
            html = "30912-10.html"
          end
        when 4
          html = "30912-15.html"
        else
          # [automatically added else]
        end

      end
    else
      # [automatically added else]
    end



    html || get_no_quest_msg(pc)
  end
end
