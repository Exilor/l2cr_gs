class Scripts::Q00269_InventionAmbition < Quest
  # NPC
  private INVENTOR_MARU = 32486
  # Items
  private ENERGY_ORE = 10866
  # Monsters
  private MONSTERS = {
    21124 => 46, # Red Eye Barbed Bat
    21125 => 48, # Northern Trimden
    21126 => 50, # Kerope Werewolf
    21127 => 64, # Northern Goblin
    21128 => 66, # Spine Golem
    21129 => 68, # Kerope Werewolf Chief
    21130 => 76, # Northern Goblin Leader
    21131 => 78  # Enchanted Spine Golem
  }
  # Misc
  private MIN_LVL = 18

  def initialize
    super(269, self.class.simple_name, "Invention Ambition")

    add_start_npc(INVENTOR_MARU)
    add_talk_id(INVENTOR_MARU)
    add_kill_id(MONSTERS.keys)
    register_quest_items(ENERGY_ORE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "32486-03.htm"
      html = pc.level >= MIN_LVL ? event : nil
    when "32486-04.htm"
      st.start_quest
      html = event
    when "32486-07.html"
      st.exit_quest(true, true)
      html = event
    when "32486-08.html"
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Rnd.rand(100) < MONSTERS[npc.id]
      st.give_items(ENERGY_ORE, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "32486-01.htm" : "32486-02.html"
    when State::STARTED
      if st.has_quest_items?(ENERGY_ORE)
        count = st.get_quest_items_count(ENERGY_ORE)
        st.give_adena((count * 50) + (count >= 10 ? 2044 : 0), true)
        st.take_items(ENERGY_ORE, -1)
        html = "32486-06.html"
      else
        html = "32486-05.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
