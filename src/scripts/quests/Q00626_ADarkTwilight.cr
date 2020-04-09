class Scripts::Q00626_ADarkTwilight < Quest
  # NPCs
  private HIERARCH = 31517
  # Items
  private BLOOD_OF_SAINT = 7169
  # Monsters
  private MONSTERS = {
    21520 => 641, # Eye of Splendor
    21523 => 648, # Flash of Splendor
    21524 => 692, # Blade of Splendor
    21525 => 710, # Blade of Splendor
    21526 => 772, # Wisdom of Splendor
    21529 => 639, # Soul of Splendor
    21530 => 683, # Victory of Splendor
    21531 => 767, # Punishment of Splendor
    21532 => 795, # Shout of Splendor
    21535 => 802, # Signet of Splendor
    21536 => 774, # Crown of Splendor
    21539 => 848, # Wailing of Splendor
    21540 => 880, # Wailing of Splendor
    21658 => 790  # Punishment of Splendor
  }
  # Misc
  private MIN_LEVEL_REQUIRED = 60
  private ITEMS_COUNT_REQUIRED = 300
  # Rewards
  private ADENA_COUNT = 100000
  private XP_COUNT = 162773
  private SP_COUNT = 12500

  def initialize
    super(626, self.class.simple_name, "A Dark Twilight")

    add_start_npc(HIERARCH)
    add_talk_id(HIERARCH)
    add_kill_id(MONSTERS.keys)
    register_quest_items(BLOOD_OF_SAINT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31517-05.html"
      # do nothing
    when "31517-02.htm"
      st.start_quest
    when "Exp"
      if st.get_quest_items_count(BLOOD_OF_SAINT) < ITEMS_COUNT_REQUIRED
        return "31517-06.html"
      end
      st.add_exp_and_sp(XP_COUNT, SP_COUNT)
      st.exit_quest(true, true)
      html = "31517-07.html"
    when "Adena"
      if st.get_quest_items_count(BLOOD_OF_SAINT) < ITEMS_COUNT_REQUIRED
        return "31517-06.html"
      end
      st.give_adena(ADENA_COUNT, true)
      st.exit_quest(true, true)
      html = "31517-07.html"
    else
      html = nil
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if member = get_random_party_member(killer, 1)
      st = get_quest_state!(member, false)
      chance = MONSTERS[npc.id] * Config.rate_quest_drop
      if Rnd.rand(1000) < chance
        st.give_items(BLOOD_OF_SAINT, 1)
        if st.get_quest_items_count(BLOOD_OF_SAINT) < ITEMS_COUNT_REQUIRED
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        else
          st.set_cond(2, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL_REQUIRED ? "31517-01.htm" : "31517-00.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "31517-03.html"
      when 2
        html = "31517-04.html"
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
