class Quests::Q00260_OrcHunting < Quest
  private RAYEN = 30221
  private ORC_AMULET = 1114
  private ORC_NECKLACE = 1115
  private MIN_LVL = 6
  private MONSTERS = {
    20468 => ORC_AMULET, # Kaboo Orc
		20469 => ORC_AMULET, # Kaboo Orc Archer
		20470 => ORC_AMULET, # Kaboo Orc Grunt
		20471 => ORC_NECKLACE, # Kaboo Orc Fighter
		20472 => ORC_NECKLACE, # Kaboo Orc Fighter Leader
		20473 => ORC_NECKLACE # Kaboo Orc Fighter Lieutenant
  }

  def initialize
    super(260, self.class.simple_name, "Orc Hunting")

    add_start_npc(RAYEN)
    add_talk_id(RAYEN)
    add_kill_id(MONSTERS.keys)
    register_quest_items(ORC_AMULET, ORC_NECKLACE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30221-04.htm"
      st.start_quest
      event
    when "30221-07.html"
      st.exit_quest(true, true)
      event
    when "30221-08.html"
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Rnd.rand(10) > 4
      st.give_items(MONSTERS[npc.id], 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state(pc, true)
    htmltext = get_no_quest_msg(pc)
    return htmltext unless st

    case st.state
    when State::CREATED
      if pc.race.elf?
        if pc.level >= MIN_LVL
          htmltext = "30221-03.htm"
        else
          htmltext = "30221-02.html"
        end
      else
        htmltext = "30221-01.html"
      end
    when State::STARTED
      if has_at_least_one_quest_item?(pc, registered_item_ids)
        amulets = st.get_quest_items_count(ORC_AMULET)
        necklaces = st.get_quest_items_count(ORC_NECKLACE)
        st.give_adena(((amulets * 12) + (necklaces * 30) + ((amulets + necklaces) >= 10 ? 1000 : 0)), true)
        take_items(pc, -1, registered_item_ids)
        Q00281_HeadForTheHills.give_newbie_reward(pc)
        htmltext = "30221-06.html"
      else
        debug "#{pc} has no quest items."
        htmltext = "30221-05.html"
      end
    end

    htmltext
  end
end
