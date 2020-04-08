class Scripts::Q10505_JewelOfValakas < Quest
  # NPC
  private KLEIN = 31540
  # Monster
  private VALAKAS = 29028
  # Items
  private EMPTY_CRYSTAL = 21906
  private FILLED_CRYSTAL_VALAKAS_ENERGY = 21908
  private JEWEL_OF_VALAKAS = 21896
  private VACUALITE_FLOATING_STONE = 7267
  # Misc
  private MIN_LEVEL = 83

  def initialize
    super(10505, self.class.simple_name, "Jewel of Valakas")

    add_start_npc(KLEIN)
    add_talk_id(KLEIN)
    add_kill_id(VALAKAS)
    register_quest_items(EMPTY_CRYSTAL, FILLED_CRYSTAL_VALAKAS_ENERGY)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, pc, false)
      take_items(pc, EMPTY_CRYSTAL, -1)
      give_items(pc, FILLED_CRYSTAL_VALAKAS_ENERGY, 1)
      play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
      st.set_cond(2, true)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL && has_quest_items?(pc, VACUALITE_FLOATING_STONE)
      case event
      when "31540-05.htm", "31540-06.htm"
        html = event
      when "31540-07.html"
        st.start_quest
        give_items(pc, EMPTY_CRYSTAL, 1)
        html = event
      else
        # automatically added
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, true)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level < MIN_LEVEL
        html = "31540-02.html"
      elsif !has_quest_items?(pc, VACUALITE_FLOATING_STONE)
        html = "31540-04.html"
      else
        html = "31540-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        if has_quest_items?(pc, EMPTY_CRYSTAL)
          html = "31540-08.html"
        else
          give_items(pc, EMPTY_CRYSTAL, 1)
          html = "31540-09.html"
        end
      when 2
        give_items(pc, JEWEL_OF_VALAKAS, 1)
        play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
        st.exit_quest(false, true)
        html = "31540-10.html"
      else
        # automatically added
      end

    when State::COMPLETED
      html = "31540-03.html"
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end