class Scripts::Q00273_InvadersOfTheHolyLand < Quest
  # NPC
  private VARKEES = 30566
  # Items
  private BLACK_SOULSTONE = 1475
  private RED_SOULSTONE = 1476
  # Monsters
  private MONSTERS = {
    20311 => 90, # Rakeclaw Imp
    20312 => 87, # Rakeclaw Imp Hunter
    20313 => 77  # Rakeclaw Imp Chieftain
  }
  # Misc
  private MIN_LVL = 6

  def initialize
    super(273, self.class.simple_name, "Invaders of the Holy Land")

    add_start_npc(VARKEES)
    add_talk_id(VARKEES)
    add_kill_id(MONSTERS.keys)
    register_quest_items(BLACK_SOULSTONE, RED_SOULSTONE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    if st
      case event
      when "30566-04.htm"
        st.start_quest
        html = event
      when "30566-08.html"
        st.exit_quest(true, true)
        html = event
      when "30566-09.html"
        html = event
      else
        # [automatically added else]
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if st = get_quest_state(killer, false)
      if Rnd.rand(100) <= MONSTERS[npc.id]
        st.give_items(BLACK_SOULSTONE, 1)
      else
        st.give_items(RED_SOULSTONE, 1)
      end
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.race.orc?
        if pc.level >= MIN_LVL
          html = "30566-03.htm"
        else
          html = "30566-02.htm"
        end
      else
        html = "30566-01.htm"
      end
    when State::STARTED
      if has_at_least_one_quest_item?(pc, BLACK_SOULSTONE, RED_SOULSTONE)
        black = st.get_quest_items_count(BLACK_SOULSTONE)
        red = st.get_quest_items_count(RED_SOULSTONE)
        adena = (red * 10) + (black * 3)
        if red > 0
          if red + black >= 10
            adena += 1800
          end
        elsif black >= 10
          adena += 1500
        end
        st.give_adena(adena, true)
        take_items(pc, -1, {BLACK_SOULSTONE, RED_SOULSTONE})
        Q00281_HeadForTheHills.give_newbie_reward(pc)
        html = red > 0 ? "30566-07.html" : "30566-06.html"
      else
        html = "30566-05.html"
      end
    else
      # [automatically added else]
    end


    html
  end
end
