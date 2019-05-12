class Scripts::Q10279_MutatedKaneusOren < Quest
  # NPCs
  private MOUEN = 30196
  private ROVIA = 30189
  private KAIM_ABIGORE = 18566
  private KNIGHT_MONTAGNAR = 18568
  # Items
  private TISSUE_KA = 13836
  private TISSUE_KM = 13837

  def initialize
    super(10279, self.class.simple_name, "Mutated Kaneus - Oren")

    add_start_npc(MOUEN)
    add_talk_id(MOUEN, ROVIA)
    add_kill_id(KAIM_ABIGORE, KNIGHT_MONTAGNAR)
    register_quest_items(TISSUE_KA, TISSUE_KM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30196-03.htm"
      st.start_quest
    when "30189-03.htm"
      st.give_adena(100000, true)
      st.exit_quest(false, true)
    end

    event
  end

  def on_kill(npc, killer, is_summon)
    unless st = get_quest_state(killer, false)
      return
    end

    npc_id = npc.id
    if party = killer.party?
      party_members = [] of QuestState
      party.members.each do |member|
        st = get_quest_state(member, false)
        if st && st.started?
          if (npc_id == KAIM_ABIGORE && !st.has_quest_items?(TISSUE_KA)) || (npc_id == KNIGHT_MONTAGNAR && !st.has_quest_items?(TISSUE_KM))
            party_members << st
          end
        end
      end

      unless party_members.empty?
        reward_item(npc_id, party_members.sample)
      end
    elsif st.started?
      reward_item(npc_id, st)
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when MOUEN
      case st.state
      when State::CREATED
        html = pc.level > 47 ? "30196-01.htm" : "30196-00.htm"
      when State::STARTED
        if st.has_quest_items?(TISSUE_KA) && st.has_quest_items?(TISSUE_KM)
          html = "30196-05.htm"
        else
          html = "30196-04.htm"
        end
      when State::COMPLETED
        html = "30916-06.htm"
      end
    when ROVIA
      case st.state
      when State::STARTED
        if st.has_quest_items?(TISSUE_KA) && st.has_quest_items?(TISSUE_KM)
          html = "30189-02.htm"
        else
          html = "30189-01.htm"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
      end
    end

    html || get_no_quest_msg(pc)
  end

  def reward_item(npc_id, st)
    if npc_id == KAIM_ABIGORE && !st.has_quest_items?(TISSUE_KA)
      st.give_items(TISSUE_KA, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif npc_id == KNIGHT_MONTAGNAR && !st.has_quest_items?(TISSUE_KM)
      st.give_items(TISSUE_KM, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end
end
