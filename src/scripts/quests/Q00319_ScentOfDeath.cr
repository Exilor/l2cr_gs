class Quests::Q00319_ScentOfDeath < Quest
  # NPC
  private MINALESS = 30138
  # Monsters
  private MARSH_ZOMBIE = 20015
  private MARSH_ZOMBIE_LORD = 20020
  # Item
  private ZOMBIES_SKIN = 1045
  private LESSER_HEALING_POTION = ItemHolder.new(1060, 1)
  # Misc
  private MIN_LEVEL = 11
  private MIN_CHANCE = 7
  private REQUIRED_ITEM_COUNT = 5

  def initialize
    super(319, self.class.simple_name, "Scent of Death")

    add_start_npc(MINALESS)
    add_talk_id(MINALESS)
    add_kill_id(MARSH_ZOMBIE, MARSH_ZOMBIE_LORD)
    register_quest_items(ZOMBIES_SKIN)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    if player.level >= MIN_LEVEL
      case event
      when "30138-04.htm"
        st.start_quest
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Util.in_range?(1500, npc, killer, false) && st.get_quest_items_count(ZOMBIES_SKIN) < REQUIRED_ITEM_COUNT
      if Rnd.rand(10) > MIN_CHANCE
        st.give_items(ZOMBIES_SKIN, 1)
        if st.get_quest_items_count(ZOMBIES_SKIN) < REQUIRED_ITEM_COUNT
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        else
          st.set_cond(2, true)
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    htmltext = get_no_quest_msg(player)
    case st.state
    when State::CREATED
      htmltext = player.level >= MIN_LEVEL ? "30138-03.htm" : "30138-02.htm"
    when State::STARTED
      case st.cond
      when 1
        htmltext = "30138-05.html"
      when 2
        st.give_adena(3350, false)
        st.give_items(LESSER_HEALING_POTION)
        st.take_items(ZOMBIES_SKIN, -1)
        st.exit_quest(true, true)
        htmltext = "30138-06.html"
      end
    end

    htmltext
  end
end
