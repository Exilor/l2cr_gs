class Scripts::Q10281_MutatedKaneusRune < Quest
  # NPCs
  private MATHIAS = 31340
  private KAYAN = 31335
  private WHITE_ALLOSCE = 18577
  # Item
  private TISSUE_WA = 13840

  def initialize
    super(10281, self.class.simple_name, "Mutated Kaneus - Rune")
    add_start_npc(MATHIAS)
    add_talk_id(MATHIAS, KAYAN)
    add_kill_id(WHITE_ALLOSCE)
    register_quest_items(TISSUE_WA)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "31340-03.htm"
      st.start_quest
    when "31335-03.htm"
      st.give_adena(360000, true)
      st.exit_quest(false, true)
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
        if st && st.started? && !st.has_quest_items?(TISSUE_WA)
          party_members << st
        end
      end

      unless party_members.empty?
        reward_item(npc_id, party_members.sample(random: Rnd))
      end
    elsif st.started? && !st.has_quest_items?(TISSUE_WA)
      reward_item(npc_id, st)
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when MATHIAS
      case st.state
      when State::CREATED
        html = pc.level > 67 ? "31340-01.htm" : "31340-00.htm"
      when State::STARTED
        html = st.has_quest_items?(TISSUE_WA) ? "31340-05.htm" : "31340-04.htm"
      when State::COMPLETED
        html = "31340-06.htm"
      end

    when KAYAN
      case st.state
      when State::STARTED
        html = st.has_quest_items?(TISSUE_WA) ? "31335-02.htm" : "31335-01.htm"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    end


    html || get_no_quest_msg(pc)
  end

  private def reward_item(npc_id, st)
    st.give_items(TISSUE_WA, 1)
    st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
  end
end
