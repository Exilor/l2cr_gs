class Scripts::Q00699_GuardianOfTheSkies < Quest
  # NPC
  private LEKON = 32557
  # Monsters
  private VALDSTONE = 25623
  private MONSTERS = {
    22614 => 840, # Vulture Rider lvl 1
    22615 => 857, # Vulture Rider lvl 2
    25633 => 719  # Vulture Rider lvl 3
  }
  # Item
  private VULTURES_GOLDEN_FEATHER = 13871
  # Misc
  private MIN_LVL = 75
  private VULTURES_GOLDEN_FEATHER_ADENA = 1500
  private BONUS = 8335
  private BONUS_COUNT = 10

  def initialize
    super(699, self.class.simple_name, "Guardian of the Skies")

    add_start_npc(LEKON)
    add_talk_id(LEKON)
    add_kill_id(VALDSTONE)
    add_kill_id(MONSTERS.keys)
    register_quest_items(VULTURES_GOLDEN_FEATHER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    if st = get_quest_state(pc, false)
      case event
      when "32557-03.htm", "32557-08.html"
        html = event
      when "32557-04.htm"
        st.start_quest
        html = event
      when "32557-09.html"
        st.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if st = get_quest_state(killer, false)
      if npc.id == VALDSTONE
        amount = 0
        chance = Rnd.rand(1000)
        if chance < 215
          amount = Rnd.rand(10) &+ 90
        elsif chance < 446
          amount = Rnd.rand(10) &+ 80
        elsif chance < 715
          amount = Rnd.rand(10) &+ 70
        else
          amount = Rnd.rand(10) &+ 60
        end
        st.give_items(VULTURES_GOLDEN_FEATHER, amount)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      else
        if Rnd.rand(1000) < MONSTERS[npc.id]
          st.give_items(VULTURES_GOLDEN_FEATHER, 1)
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
      st = pc.get_quest_state(Q10273_GoodDayToFly.simple_name)
      if st.nil? || !st.completed? || pc.level < MIN_LVL
        html = "32557-02.htm"
      else
        html = "32557-01.htm"
      end
    when State::STARTED
      feathers = st.get_quest_items_count(VULTURES_GOLDEN_FEATHER)
      if feathers > 0
        adena = feathers &* VULTURES_GOLDEN_FEATHER_ADENA
        if feathers > BONUS_COUNT
          adena += BONUS
        end
        st.give_adena(adena, true)
        st.take_items(VULTURES_GOLDEN_FEATHER, -1)
        html = feathers > BONUS_COUNT ? "32557-07.html" : "32557-06.html"
      else
        html = "32557-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
