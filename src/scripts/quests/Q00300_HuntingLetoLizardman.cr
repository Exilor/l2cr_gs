class Scripts::Q00300_HuntingLetoLizardman < Quest
  # NPCs
  private RATH = 30126
  # Items
  private BRACELET_OF_LIZARDMAN = 7139
  private REWARD_ADENA = ItemHolder.new(Inventory::ADENA_ID, 30000)
  private REWARD_ANIMAL_BONE = ItemHolder.new(1872, 50)
  private REWARD_ANIMAL_SKIN = ItemHolder.new(1867, 50)
  # Misc
  private MIN_LEVEL = 34
  private REQUIRED_BRACELET_COUNT = 60
  # Monsters
  private MOBS_SAC = {
    20577 => 360, # Leto Lizardman
    20578 => 390, # Leto Lizardman Archer
    20579 => 410, # Leto Lizardman Soldier
    20580 => 790, # Leto Lizardman Warrior
    20582 => 890  # Leto Lizardman Overlord
  }

  def initialize
    super(300, self.class.simple_name, "Hunting Leto Lizardman")

    add_start_npc(RATH)
    add_talk_id(RATH)
    add_kill_id(MOBS_SAC.keys)
    register_quest_items(BRACELET_OF_LIZARDMAN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30126-03.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "30126-06.html"
      if st.get_quest_items_count(BRACELET_OF_LIZARDMAN) >= REQUIRED_BRACELET_COUNT
        st.take_items(BRACELET_OF_LIZARDMAN, -1)
        rand = rand(1000)
        if rand < 500
          give_items(pc, REWARD_ADENA)
        elsif rand < 750
          give_items(pc, REWARD_ANIMAL_SKIN)
        elsif rand < 1000
          give_items(pc, REWARD_ANIMAL_BONE)
        end
        st.exit_quest(true, true)
        html = event
      else
        html = "30126-07.html"
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if m = get_random_party_member(pc, 1)
      st = get_quest_state!(m, false)
      if st.cond?(1) && rand(1000) < MOBS_SAC[npc.id]
        st.give_items(BRACELET_OF_LIZARDMAN, 1)
        if st.get_quest_items_count(BRACELET_OF_LIZARDMAN) == REQUIRED_BRACELET_COUNT
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30126-01.htm" : "30126-02.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "30126-04.html"
      when 2
        if st.get_quest_items_count(BRACELET_OF_LIZARDMAN) >= REQUIRED_BRACELET_COUNT
          html = "30126-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
