class Scripts::Q10277_MutatedKaneusDion < Quest
  # NPCs
  private LUKAS = 30071
  private MIRIEN = 30461
  private CRIMSON_HATU = 18558
  private SEER_FLOUROS = 18559
  # Items
  private TISSUE_CH = 13832
  private TISSUE_SF = 13833

  def initialize
    super(10277, self.class.simple_name, "Mutated Kaneus - Dion")

    add_start_npc(LUKAS)
    add_talk_id(LUKAS, MIRIEN)
    add_kill_id(CRIMSON_HATU, SEER_FLOUROS)
    register_quest_items(TISSUE_CH, TISSUE_SF)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30071-03.html"
      st.start_quest
    when "30461-03.html"
      st.give_adena(20000, true)
      st.exit_quest(false, true)
    else
      # automatically added
    end


    event
  end

  def on_kill(npc, killer, is_summon)
    unless st = get_quest_state(killer, false)
      return super
    end

    npc_id = npc.id
    if party = killer.party
      party_members = [] of QuestState
      party.members.each do |member|
        st = get_quest_state(member, false)
        if st && st.started?
          if (npc_id == CRIMSON_HATU && !st.has_quest_items?(TISSUE_CH)) || (npc_id == SEER_FLOUROS && !st.has_quest_items?(TISSUE_SF))
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

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when LUKAS
      case st.state
      when State::CREATED
        html = pc.level > 27 ? "30071-01.htm" : "30071-00.html"
      when State::STARTED
        if st.has_quest_items?(TISSUE_CH) && st.has_quest_items?(TISSUE_SF)
          html = "30071-05.html"
        else
          html = "30071-04.html"
        end
      when State::COMPLETED
        html = "30071-06.html"
      else
        # automatically added
      end

    when MIRIEN
      case st.state
      when State::STARTED
        if st.has_quest_items?(TISSUE_CH) && st.has_quest_items?(TISSUE_SF)
          html = "30461-02.html"
        else
          html = "30461-01.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end

  private def reward_item(npc_id, st)
    if npc_id == CRIMSON_HATU && !st.has_quest_items?(TISSUE_CH)
      st.give_items(TISSUE_CH, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif npc_id == SEER_FLOUROS && !st.has_quest_items?(TISSUE_SF)
      st.give_items(TISSUE_SF, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end
end