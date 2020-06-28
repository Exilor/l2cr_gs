class Scripts::Q00274_SkirmishWithTheWerewolves < Quest
  # NPC
  private BRUKURSE = 30569
  # Monsters
  private MONSTERS = {
    20363, # Maraku Werewolf
    20364  # Maraku Werewolf Chieftain
  }
  # Items
  private NECKLACE_OF_COURAGE = 1506
  private NECKLACE_OF_VALOR = 1507
  private WEREWOLF_HEAD = 1477
  private WEREWOLF_TOTEM = 1501
  # Misc
  private MIN_LVL = 9

  def initialize
    super(274, self.class.simple_name, "Skirmish with the Werewolves")

    add_start_npc(BRUKURSE)
    add_talk_id(BRUKURSE)
    add_kill_id(MONSTERS)
    register_quest_items(WEREWOLF_HEAD, WEREWOLF_TOTEM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30569-04.htm")
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      st.give_items(WEREWOLF_HEAD, 1)
      if Rnd.rand(100) <= 5
        st.give_items(WEREWOLF_TOTEM, 1)
      end
      if st.get_quest_items_count(WEREWOLF_HEAD) >= 40
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
      if has_at_least_one_quest_item?(pc, NECKLACE_OF_VALOR, NECKLACE_OF_COURAGE)
        if pc.race.orc?
          if pc.level >= MIN_LVL
            html = "30569-03.htm"
          else
            html = "30569-02.html"
          end
        else
          html = "30569-01.html"
        end
      else
        html = "30569-08.html"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "30569-05.html"
      when 2
        heads = st.get_quest_items_count(WEREWOLF_HEAD)
        if heads >= 40
          totems = st.get_quest_items_count(WEREWOLF_TOTEM)
          st.give_adena((heads * 30) + (totems * 600) + 2300, true)
          st.exit_quest(true, true)
          html = totems > 0 ? "30569-07.html" : "30569-06.html"
        end
      end

    end


    html || get_no_quest_msg(pc)
  end
end
