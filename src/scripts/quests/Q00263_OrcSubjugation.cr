class Scripts::Q00263_OrcSubjugation < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30346-04.htm"
      st.start_quest
      html = event
    when "30346-07.html"
      st.exit_quest(true, true)
      html = event
    when "30346-08.html"
      html = event
    else
      # [automatically added else]
    end


    html
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
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.race == Race::DARK_ELF
        if pc.level >= MIN_LEVEL
          html = "30346-03.htm"
        else
          html = "30346-02.htm"
        end
      else
        html = "30346-01.htm"
      end
    when State::STARTED
      if has_at_least_one_quest_item?(pc, registered_item_ids)
        amulets = st.get_quest_items_count(ORC_AMULET)
        necklaces = st.get_quest_items_count(ORC_NECKLACE)
        adena = (amulets * 20) + (necklaces * 30)
        adena += (amulets + necklaces >= 10 ? 1100 : 0)
        st.give_adena(adena, true)
        take_items(pc, -1, registered_item_ids)
        html = "30346-06.html"
      else
        html = "30346-05.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
