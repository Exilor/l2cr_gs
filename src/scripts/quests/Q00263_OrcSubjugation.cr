class Quests::Q00263_OrcSubjugation < Quest
  # NPCs
  private KAYLEEN = 30346
  # Items
  private ORC_AMULET = 1116
  private ORC_NECKLACE = 1117
  # Misc
  private MIN_LEVEL = 8
  # Monsters
  private MONSTERS = {
    20385 => ORC_AMULET,   # Balor Orc Archer
    20386 => ORC_NECKLACE, # Balor Orc Fighter
    20387 => ORC_NECKLACE, # Balor Orc Fighter Leader
    20388 => ORC_NECKLACE  # Balor Orc Lieutenant
  }

  def initialize
    super(263, self.class.simple_name, "Orc Subjugation")

    add_start_npc(KAYLEEN)
    add_talk_id(KAYLEEN)
    add_kill_id(MONSTERS.keys)
    register_quest_items(ORC_AMULET, ORC_NECKLACE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    case event
    when "30346-04.htm"
      st.start_quest
      htmltext = event
    when "30346-07.html"
      st.exit_quest(true, true)
      htmltext = event
    when "30346-08.html"
      htmltext = event
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Rnd.rand(10) > 4
      st.give_items(MONSTERS[npc.id], 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      htmltext = player.race == Race::DARK_ELF ? player.level >= MIN_LEVEL ? "30346-03.htm" : "30346-02.htm" : "30346-01.htm"
    when State::STARTED
      if has_at_least_one_quest_item?(player, registered_item_ids)
         amulets = st.get_quest_items_count(ORC_AMULET)
         necklaces = st.get_quest_items_count(ORC_NECKLACE)
        st.give_adena(((amulets * 20) + (necklaces * 30) + ((amulets + necklaces) >= 10 ? 1100 : 0)), true)
        take_items(player, -1, registered_item_ids)
        htmltext = "30346-06.html"
      else
        htmltext = "30346-05.html"
      end
    end

    htmltext
  end
end
