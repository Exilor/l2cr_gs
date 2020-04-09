class Scripts::Q00143_FallenAngelRequestOfDusk < Quest
  # NPCs
  private TOBIAS = 30297
  private CASIAN = 30612
  private NATOOLS = 30894
  private ROCK = 32368
  private ANGEL = 32369
  # Items
  private SEALED_PROPHECY_PATH_OF_THE_GOD = 10354
  private PROPHECY_PATH_OF_THE_GOD = 10355
  private EMPTY_SOUND_CRYSTAL = 10356
  private ANGEL_MEDICINE = 10357
  private ANGELS_MESSAGE = 10358
  # Misc
  private MAX_REWARD_LEVEL = 43

  @angel_spawned = false

  def initialize
    super(143, self.class.simple_name, "Fallen Angel - Request of Dusk")

    add_talk_id(NATOOLS, TOBIAS, CASIAN, ROCK, ANGEL)
    register_quest_items(
      SEALED_PROPHECY_PATH_OF_THE_GOD, PROPHECY_PATH_OF_THE_GOD,
      EMPTY_SOUND_CRYSTAL, ANGEL_MEDICINE, ANGELS_MESSAGE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30894-02.html", "30297-04.html", "30612-05.html", "30612-06.html",
         "30612-07.html", "30612-08.html", "32369-04.html", "32369-05.html",
         "32369-07.html", "32369-08.html", "32369-09.html", "32369-10.html"
      # do nothing
    when "30894-01.html"
      st.start_quest
    when "30894-03.html"
      st.set_cond(2, true)
      st.give_items(SEALED_PROPHECY_PATH_OF_THE_GOD, 1)
    when "30297-03.html"
      st.take_items(SEALED_PROPHECY_PATH_OF_THE_GOD, -1)
      st.set("talk", "1")
    when "30297-05.html"
      st.unset("talk")
      st.set_cond(3, true)
      st.give_items(PROPHECY_PATH_OF_THE_GOD, 1)
      st.give_items(EMPTY_SOUND_CRYSTAL, 1)
    when "30612-03.html"
      st.take_items(PROPHECY_PATH_OF_THE_GOD, -1)
      st.set("talk", "1")
    when "30612-09.html"
      st.unset("talk")
      st.set_cond(4, true)
      st.give_items(ANGEL_MEDICINE, 1)
    when "32368-04.html"
      if @angel_spawned
        return "32368-03.html"
      end
      npc = npc.not_nil!
      add_spawn(ANGEL, npc.x + 100, npc.y + 100, npc.z, 0, false, 120000)
      start_quest_timer("despawn", 120000, nil, pc)
      @angel_spawned = true
    when "32369-03.html"
      st.take_items(ANGEL_MEDICINE, -1)
      st.set("talk", "1")
    when "32369-06.html"
      st.set("talk", "2")
    when "32369-11.html"
      npc = npc.not_nil!
      st.unset("talk")
      st.take_items(EMPTY_SOUND_CRYSTAL, -1)
      st.give_items(ANGELS_MESSAGE, 1)
      st.set_cond(5, true)
      npc.delete_me
      @angel_spawned = false
    when "despawn"
      if @angel_spawned
        @angel_spawned = false
      end
    else
      html = nil
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when NATOOLS
      case st.state
      when State::STARTED
        case st.cond
        when 1
          html = "30894-01.html"
        else
          html = "30894-04.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when TOBIAS
      if st.started?
        case st.cond
        when 1
          html = "30297-01.html"
        when 2
          html = st.set?("talk") ? "30297-04.html" : "30297-02.html"
        when 3, 4
          html = "30297-06.html"
        when 5
          st.give_adena(89046, true)
          if pc.level <= MAX_REWARD_LEVEL
            st.add_exp_and_sp(223036, 13901)
          end
          st.exit_quest(false, true)
          html = "30297-07.html"
        else
          # [automatically added else]
        end

      end
    when CASIAN
      if st.started?
        case st.cond
        when 1, 2
          html = "30612-01.html"
        when 3
          html = st.set?("talk") ? "30612-04.html" : "30612-02.html"
        else
          html = "30612-10.html"
        end
      end
    when ROCK
      if st.started?
        case st.cond
        when 1..3
          html = "32368-01.html"
        when 4
          html = "32368-02.html"
        when 5
          html = "32368-05.html"
        else
          # [automatically added else]
        end

      end
    when ANGEL
      if st.started?
        case st.cond
        when 1..3
          html = "32369-01.html"
        when 4
          if st.get_int("talk") == 1
            html = "32369-04.html"
          elsif st.get_int("talk") == 2
            html = "32369-07.html"
          else
            html = "32369-02.html"
          end
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
