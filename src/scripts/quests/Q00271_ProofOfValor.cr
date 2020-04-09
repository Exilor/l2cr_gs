class Scripts::Q00271_ProofOfValor < Quest
  # NPC
  private RUKAIN = 30577
  # Items
  private KASHA_WOLF_FANG = 1473
  # Monsters
  private KASHA_WOLF = 20475
  # Rewards
  private HEALING_POTION = 1061
  private NECKLACE_OF_COURAGE = 1506
  private NECKLACE_OF_VALOR = 1507
  # Misc
  private MIN_LVL = 4

  def initialize
    super(271, self.class.simple_name, "Proof of Valor")

    add_start_npc(RUKAIN)
    add_talk_id(RUKAIN)
    add_kill_id(KASHA_WOLF)
    register_quest_items(KASHA_WOLF_FANG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    if event.casecmp?("30577-04.htm")
      st.start_quest
      if has_at_least_one_quest_item?(pc, NECKLACE_OF_VALOR, NECKLACE_OF_COURAGE)
        "30577-08.html"
      else
        event
      end
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      count = st.get_quest_items_count(KASHA_WOLF_FANG)
      amount = Rnd.rand(100) < 25 && count < 49 ? 2 : 1
      st.give_items(KASHA_WOLF_FANG, amount)
      if count + amount >= 50
        st.set_cond(2, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.race.orc?
        if pc.level >= MIN_LVL
          if has_at_least_one_quest_item?(pc, NECKLACE_OF_VALOR, NECKLACE_OF_COURAGE)
            html = "30577-07.htm"
          else
            html = "30577-03.htm"
          end
        else
          html = "30577-02.htm"
        end
      else
        html = "30577-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "30577-05.html"
      when 2
        if st.get_quest_items_count(KASHA_WOLF_FANG) >= 50
          if Rnd.rand(100) <= 13
            st.reward_items(NECKLACE_OF_VALOR, 1)
            st.reward_items(HEALING_POTION, 10)
          else
            st.reward_items(NECKLACE_OF_COURAGE, 1)
          end
          st.take_items(KASHA_WOLF_FANG, -1)
          st.exit_quest(true, true)
          html = "30577-06.html"
        end
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html
  end
end
