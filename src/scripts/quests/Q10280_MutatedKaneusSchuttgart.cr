class Scripts::Q10280_MutatedKaneusSchuttgart < Quest
  # NPCs
  private VISHOTSKY = 31981
  private ATRAXIA = 31972
  private VENOMOUS_STORACE = 18571
  private KEL_BILETTE = 18573
  # Items
  private TISSUE_VS = 13838
  private TISSUE_KB = 13839

  def initialize
    super(10280, self.class.simple_name, "Mutated Kaneus - Schuttgart")

    add_start_npc(VISHOTSKY)
    add_talk_id(VISHOTSKY, ATRAXIA)
    add_kill_id(VENOMOUS_STORACE, KEL_BILETTE)
    register_quest_items(TISSUE_VS, TISSUE_KB)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "31981-03.htm"
      st.start_quest
    when "31972-03.htm"
      st.give_adena(210000, true)
      st.exit_quest(false, true)
    else
      # [automatically added else]
    end


    event
  end

  def on_kill(npc, killer, is_summon)
    unless st = get_quest_state(killer, false)
      return
    end

    npc_id = npc.id
    if party = killer.party
      party_members = [] of QuestState
      party.members.each do |member|
        st = get_quest_state(member, false)
        if st && st.started?
          if (npc_id == VENOMOUS_STORACE && !st.has_quest_items?(TISSUE_VS)) || (npc_id == KEL_BILETTE && !st.has_quest_items?(TISSUE_KB))
            party_members << st
          end
        end
      end

      unless party_members.empty?
        reward_item(npc_id, party_members.sample(random: Rnd))
      end
    elsif st.started?
      reward_item(npc_id, st)
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when VISHOTSKY
      case st.state
      when State::CREATED
        html = pc.level > 57 ? "31981-01.htm" : "31981-00.htm"
      when State::STARTED
        if st.has_quest_items?(TISSUE_VS) && st.has_quest_items?(TISSUE_KB)
          html = "31981-05.htm"
        else
          html = "31981-04.htm"
        end
      when State::COMPLETED
        html = "31981-06.htm"
      else
        # [automatically added else]
      end

    when ATRAXIA
      case st.state
      when State::STARTED
        if st.has_quest_items?(TISSUE_VS) && st.has_quest_items?(TISSUE_KB)
          html = "31972-02.htm"
        else
          html = "31972-01.htm"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end

  private def reward_item(npc_id, st)
    if npc_id == VENOMOUS_STORACE && !st.has_quest_items?(TISSUE_VS)
      st.give_items(TISSUE_VS, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif npc_id == KEL_BILETTE && !st.has_quest_items?(TISSUE_KB)
      st.give_items(TISSUE_KB, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end
end
