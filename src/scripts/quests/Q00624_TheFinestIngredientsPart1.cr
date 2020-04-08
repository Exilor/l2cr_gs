class Scripts::Q00624_TheFinestIngredientsPart1 < Quest
  # NPC
  private JEREMY = 31521
  # Items
  private TRUNK_OF_NEPENTHES = 7202
  private FOOT_OF_BANDERSNATCHLING = 7203
  private SECRET_SPICE = 7204
  # Rewards
  private ICE_CRYSTAL = 7080
  private SOY_SAUCE_JAR = 7205
  # Misc
  private MIN_LVL = 73
  private MONSTER_DROPS = {
    21314 => FOOT_OF_BANDERSNATCHLING, # Hot Springs Bandersnatchling
    21317 => SECRET_SPICE, # Hot Springs Atroxspawn
    21319 => TRUNK_OF_NEPENTHES, # Hot Springs Nepenthes
    21321 => SECRET_SPICE # Hot Springs Atrox
  }

  def initialize
    super(624, self.class.simple_name, "The Finest Ingredients - Part 1")

    add_start_npc(JEREMY)
    add_talk_id(JEREMY)
    add_kill_id(MONSTER_DROPS.keys)
    register_quest_items(
      TRUNK_OF_NEPENTHES, FOOT_OF_BANDERSNATCHLING, SECRET_SPICE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "31521-02.htm"
      st.start_quest
      html = event
    when "31521-05.html"
      if st.cond?(2) && get_quest_items_count(pc, registered_item_ids) == 150
        st.give_items(ICE_CRYSTAL, 1)
        st.give_items(SOY_SAUCE_JAR, 1)
        st.exit_quest(true, true)
        html = "31521-05.html"
      else
        html = "31521-06.html"
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    m = get_random_party_member(killer, 1)
    if m && m.inside_radius?(npc, 1500, true, false)
      item = MONSTER_DROPS[npc.id]
      count = get_quest_items_count(m, item)
      if count + 1 >= 50
        if count < 50
          give_items(m, item, 50 - count)
          play_sound(m, Sound::ITEMSOUND_QUEST_FANFARE_MIDDLE)
        end
        if get_quest_items_count(m, registered_item_ids) == 150
          get_quest_state!(m, false).set_cond(2, true)
        end
      else
        give_items(m, item, 1)
        play_sound(m, Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "31521-01.htm" : "31521-00.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "31521-03.html"
      when 2
        html = "31521-04.html"
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end