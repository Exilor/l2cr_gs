class Quests::Q00287_FiguringItOut < Quest
  # NPCs
  private LAKI = 32742
  private MONSTERS = {
    22768 => 509, # Tanta Lizardman Scout
    22769 => 689, # Tanta Lizardman Warrior
    22770 => 123, # Tanta Lizardman Soldier
    22771 => 159, # Tanta Lizardman Berserker
    22772 => 739, # Tanta Lizardman Archer
    22773 => 737, # Tanta Lizardman Magician
    22774 => 261  # Tanta Lizardman Summoner
  }

  # Items
  private VIAL_OF_TANTA_BLOOD = 15499
  # Rewards
  private MOIRAI = {
    ItemHolder.new(15776, 1),
    ItemHolder.new(15779, 1),
    ItemHolder.new(15782, 1),
    ItemHolder.new(15785, 1),
    ItemHolder.new(15788, 1),
    ItemHolder.new(15812, 1),
    ItemHolder.new(15813, 1),
    ItemHolder.new(15814, 1),
    ItemHolder.new(15646, 5),
    ItemHolder.new(15649, 5),
    ItemHolder.new(15652, 5),
    ItemHolder.new(15655, 5),
    ItemHolder.new(15658, 5),
    ItemHolder.new(15772, 1),
    ItemHolder.new(15773, 1),
    ItemHolder.new(15774, 1)
  }

  private ICARUS = {
    ItemHolder.new(10381, 1),
    ItemHolder.new(10405, 1),
    ItemHolder.new(10405, 4),
    ItemHolder.new(10405, 4),
    ItemHolder.new(10405, 6),
  }

  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(287, self.class.simple_name, "Figuring It Out!")

    add_start_npc(LAKI)
    add_talk_id(LAKI)
    add_kill_id(MONSTERS.keys)
    register_quest_items(VIAL_OF_TANTA_BLOOD)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    html = event
    case event
    when "32742-03.htm"
      st.start_quest
    when "Icarus"
      if st.get_quest_items_count(VIAL_OF_TANTA_BLOOD) >= 500
        holder = ICARUS.sample
        st.give_items(holder)
        st.take_items(VIAL_OF_TANTA_BLOOD, 500)
        st.play_sound(Sound::ITEMSOUND_QUEST_FINISH)
        html = "32742-06.html"
      else
        html = "32742-07.html"
      end
    when "Moirai"
      if st.get_quest_items_count(VIAL_OF_TANTA_BLOOD) >= 100
        holder = MOIRAI.sample
        st.give_items(holder)
        st.take_items(VIAL_OF_TANTA_BLOOD, 100)
        st.play_sound(Sound::ITEMSOUND_QUEST_FINISH)
        html = "32742-08.html"
      else
        html = "32742-09.html"
      end
    when "32742-11.html"
      unless st.has_quest_items?(VIAL_OF_TANTA_BLOOD)
        st.exit_quest(true, true)
        html = "32742-12.html"
      end
    when "32742-13.html"
      st.exit_quest(true, true)
    when "32742-02.htm", "32742-10.html"
    else
      html = nil
    end

    html
  end

  def on_kill(npc, player, is_summon)
    unless m = get_random_party_member(player, 1)
      return super
    end

    st = get_quest_state!(m, false)

    if rand(1000) < MONSTERS[npc.id]
      st.give_items(VIAL_OF_TANTA_BLOOD, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      if player.level >= MIN_LEVEL && player.quest_completed?(Q00250_WatchWhatYouEat.simple_name)
        html = "32742-01.htm"
      else
        html = "32742-14.htm"
      end
    when State::STARTED
      if st.get_quest_items_count(VIAL_OF_TANTA_BLOOD) < 100
        html = "32742-04.html"
      else
        html = "32742-05.html"
      end
    end

    html || get_no_quest_msg(player)
  end
end
