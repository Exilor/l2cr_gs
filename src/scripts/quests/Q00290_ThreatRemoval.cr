class Scripts::Q00290_ThreatRemoval < Quest
  # NPC
  private PINAPS = 30201
  # Items
  private ENCHANT_WEAPON_S = 959
  private ENCHANT_ARMOR_S = 960
  private FIRE_CRYSTAL = 9552
  private SEL_MAHUM_ID_TAG = 15714
  # Misc
  private MIN_LEVEL = 82

  private MOBS_TAG = {
    22775 => 932, # Sel Mahum Drill Sergeant
    22776 => 397, # Sel Mahum Training Officer
    22777 => 932, # Sel Mahum Drill Sergeant
    22778 => 932, # Sel Mahum Drill Sergeant
    22780 => 363, # Sel Mahum Recruit
    22781 => 483, # Sel Mahum Soldier
    22782 => 363, # Sel Mahum Recruit
    22783 => 352, # Sel Mahum Soldier
    22784 => 363, # Sel Mahum Recruit
    22785 => 169, # Sel Mahum Soldier
  }

  def initialize
    super(290, self.class.simple_name, "Threat Removal")

    add_start_npc(PINAPS)
    add_talk_id(PINAPS)
    add_kill_id(MOBS_TAG.keys)
    register_quest_items(SEL_MAHUM_ID_TAG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30201-02.html"
      st.start_quest
      html = event
    when "30201-06.html"
      if st.cond?(1)
        st.take_items(SEL_MAHUM_ID_TAG, 400)
        case Rnd.rand(10)
        when 0
          st.reward_items(ENCHANT_WEAPON_S, 1)
        when 1..3
          st.reward_items(ENCHANT_ARMOR_S, 1)
        when 4, 5
          st.reward_items(ENCHANT_ARMOR_S, 2)
        when 6
          st.reward_items(ENCHANT_ARMOR_S, 3)
        when 7, 8
          st.reward_items(FIRE_CRYSTAL, 1)
        when 9, 10
          st.reward_items(FIRE_CRYSTAL, 2)
        end


        html = event
      end
    when "30201-07.html"
      if st.cond?(1)
        html = event
      end
    when "exit"
      if st.cond?(1)
        if st.has_quest_items?(SEL_MAHUM_ID_TAG)
          html = "30201-08.html"
        else
          st.exit_quest(true, true)
          html = "30201-09.html"
        end
      end
    when "30201-10.html"
      if st.cond?(1)
        st.exit_quest(true, true)
        html = event
      end
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    unless m = get_random_party_member(pc, 1)
      return super
    end

    st = get_quest_state!(m, false)
    npc_id = npc.id
    chance = MOBS_TAG[npc_id] * Config.rate_quest_drop
    if Rnd.rand(1000) < chance
      st.reward_items(SEL_MAHUM_ID_TAG, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00251_NoSecrets.simple_name)
        html = "30201-01.htm"
      else
        html = "30201-03.html"
      end
    when State::STARTED
      if st.cond?(1)
        if st.get_quest_items_count(SEL_MAHUM_ID_TAG) < 400
          html = "30201-04.html"
        else
          html = "30201-05.html"
        end
      end
    end


    html || get_no_quest_msg(pc)
  end
end
