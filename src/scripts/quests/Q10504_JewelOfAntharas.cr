class Scripts::Q10504_JewelOfAntharas < Quest
  # NPC
  private THEODRIC = 30755
  # Monster
  private ANTHARAS = 29068
  # Items
  private CLEAR_CRYSTAL = 21905
  private FILLED_CRYSTAL_ANTHARAS_ENERGY = 21907
  private JEWEL_OF_ANTHARAS = 21898
  private PORTAL_STONE = 3865
  # Misc
  private MIN_LEVEL = 84

  def initialize
    super(10504, self.class.simple_name, "Jewel of Antharas")

    add_start_npc(THEODRIC)
    add_talk_id(THEODRIC)
    add_kill_id(ANTHARAS)
    register_quest_items(CLEAR_CRYSTAL, FILLED_CRYSTAL_ANTHARAS_ENERGY)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, pc, false)
      take_items(pc, CLEAR_CRYSTAL, -1)
      give_items(pc, FILLED_CRYSTAL_ANTHARAS_ENERGY, 1)
      play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
      st.set_cond(2, true)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL && has_quest_items?(pc, PORTAL_STONE)
      case event
      when "30755-05.htm", "30755-06.htm"
        html = event
      when "30755-07.html"
        st.start_quest
        give_items(pc, CLEAR_CRYSTAL, 1)
        html = event
      else
        # [automatically added else]
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
        html = "30755-02.html"
      elsif !has_quest_items?(pc, PORTAL_STONE)
        html = "30755-04.html"
      else
        html = "30755-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        if has_quest_items?(pc, CLEAR_CRYSTAL)
          html = "30755-08.html"
        else
          give_items(pc, CLEAR_CRYSTAL, 1)
          html = "30755-09.html"
        end
      when 2
        give_items(pc, JEWEL_OF_ANTHARAS, 1)
        play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
        st.exit_quest(false, true)
        html = "30755-10.html"
      else
        # [automatically added else]
      end

    when State::COMPLETED
      html = "30755-03.html"
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
