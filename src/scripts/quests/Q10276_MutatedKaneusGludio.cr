class Scripts::Q10276_MutatedKaneusGludio < Quest
  # NPCs
  private BATHIS = 30332
  private ROHMER = 30344
  private TOMLAN_KAMOS = 18554
  private OL_ARIOSH = 18555
  # Items
  private TISSUE_TK = 13830
  private TISSUE_OA = 13831

  def initialize
    super(10276, self.class.simple_name, "Mutated Kaneus - Gludio")

    add_start_npc(BATHIS)
    add_talk_id(BATHIS, ROHMER)
    add_kill_id(TOMLAN_KAMOS, OL_ARIOSH)
    register_quest_items(TISSUE_TK, TISSUE_OA)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30332-03.htm"
      st.start_quest
    when "30344-03.htm"
      st.give_adena(8500, true)
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
        next unless st && st.started?
        if (npc_id == TOMLAN_KAMOS && !st.has_quest_items?(TISSUE_TK)) || (npc_id == OL_ARIOSH && !st.has_quest_items?(TISSUE_OA))
          party_members << st
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
    when BATHIS
      case st.state
      when State::CREATED
        html = pc.level > 17 ? "30332-01.htm" : "30332-00.htm"
      when State::STARTED
        if st.has_quest_items?(TISSUE_TK) && st.has_quest_items?(TISSUE_OA)
          html = "30332-05.htm"
        else
          html = "30332-04.htm"
        end
      when State::COMPLETED
        html = "30332-06.htm"
      end
    when ROHMER
      case st.state
      when State::STARTED
        if st.has_quest_items?(TISSUE_TK) && st.has_quest_items?(TISSUE_OA)
          html = "30344-02.htm"
        else
          html = "30344-01.htm"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def reward_item(npc_id, st)
    if npc_id == TOMLAN_KAMOS && !st.has_quest_items?(TISSUE_TK)
      st.give_items(TISSUE_TK, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif npc_id == OL_ARIOSH && !st.has_quest_items?(TISSUE_OA)
      st.give_items(TISSUE_OA, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end
end
