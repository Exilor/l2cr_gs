class Scripts::Q00645_GhostsOfBatur < Quest
  # NPC
  private KARUDA = 32017
  # Monsters
  private CONTAMINATED_MOREK_WARRIOR = 22703
  private CONTAMINATED_BATUR_WARRIOR = 22704
  private CONTAMINATED_BATUR_COMMANDER = 22705
  # Items
  private CURSED_GRAVE_GOODS = 8089 # Old item
  private CURSED_BURIAL_ITEMS = 14861 # New item
  # Misc
  private MIN_LEVEL = 80
  private CHANCES = {
    516,
    664,
    686
  }

  def initialize
    super(645, self.class.simple_name, "Ghosts of Batur")

    add_start_npc(KARUDA)
    add_talk_id(KARUDA)
    add_kill_id(
      CONTAMINATED_MOREK_WARRIOR, CONTAMINATED_BATUR_WARRIOR,
      CONTAMINATED_BATUR_COMMANDER
    )
    register_quest_items(CURSED_GRAVE_GOODS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL
      case event
      when "32017-03.htm"
        st.start_quest
        html = event
      when "32017-06.html", "32017-08.html"
        html = event
      when "32017-09.html"
        st.exit_quest(true, true)
        html = event
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    pc = get_random_party_member(killer, 1)
    if pc && Util.in_range?(1500, npc, pc, false)
      if Rnd.rand(1000) < CHANCES[npc.id - CONTAMINATED_MOREK_WARRIOR]
        st = get_quest_state!(pc, false)
        st.give_items(CURSED_BURIAL_ITEMS, 1)
        if st.cond?(1) && st.get_quest_items_count(CURSED_BURIAL_ITEMS) >= 500
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
      html = pc.level >= MIN_LEVEL ? "32017-01.htm" : "32017-02.html"
    when State::STARTED
      # Support for old quest reward.
      count = st.get_quest_items_count(CURSED_GRAVE_GOODS)
      if count > 0 && count < 180
        st.give_adena(56000 + (count * 64), false)
        st.add_exp_and_sp(138000, 7997)
        st.exit_quest(true, true)
        html = "32017-07.html"
      else
        if st.has_quest_items?(CURSED_BURIAL_ITEMS)
          html = "32017-04.html"
        else
          html = "32017-05.html"
        end
      end
    end


    html || get_no_quest_msg(pc)
  end
end
