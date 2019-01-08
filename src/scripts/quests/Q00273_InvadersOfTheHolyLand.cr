class Quests::Q00273_InvadersOfTheHolyLand < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    if st
      case event
      when "30566-04.htm"
        st.start_quest
        htmltext = event
      when "30566-08.html"
        st.exit_quest(true, true)
        htmltext = event
      when "30566-09.html"
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st
      if Rnd.rand(100) <= MONSTERS[npc.id]
        st.give_items(BLACK_SOULSTONE, 1)
      else
        st.give_items(RED_SOULSTONE, 1)
      end
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      htmltext = player.race.orc? ? player.level >= MIN_LVL ? "30566-03.htm" : "30566-02.htm" : "30566-01.htm"
    when State::STARTED
      if has_at_least_one_quest_item?(player, BLACK_SOULSTONE, RED_SOULSTONE)
        black = st.get_quest_items_count(BLACK_SOULSTONE)
        red = st.get_quest_items_count(RED_SOULSTONE)
        st.give_adena((red * 10) + (black * 3) + ((red > 0) ? (((red + black) >= 10) ? 1800 : 0) : ((black >= 10) ? 1500 : 0)), true)
        take_items(player, -1, {BLACK_SOULSTONE, RED_SOULSTONE})
        Q00281_HeadForTheHills.give_newbie_reward(player)
        htmltext = red > 0 ? "30566-07.html" : "30566-06.html"
      else
        htmltext = "30566-05.html"
      end
    end

    htmltext
  end
end
