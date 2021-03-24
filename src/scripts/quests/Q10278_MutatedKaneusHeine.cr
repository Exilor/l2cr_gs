class Scripts::Q10278_MutatedKaneusHeine < Quest
  # NPCs
  private GOSTA = 30916
  private MINEVIA = 30907
  private BLADE_OTIS = 18562
  private WEIRD_BUNEI = 18564
  # Items
  private TISSUE_BO = 13834
  private TISSUE_WB = 13835

  def initialize
    super(10278, self.class.simple_name, "Mutated Kaneus - Heine")

    add_start_npc(GOSTA)
    add_talk_id(GOSTA, MINEVIA)
    add_kill_id(BLADE_OTIS, WEIRD_BUNEI)
    register_quest_items(TISSUE_BO, TISSUE_WB)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30916-03.htm"
      st.start_quest
    when "30907-03.htm"
      st.give_adena(50_000, true)
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
        if st && st.started?
          if (npc_id == BLADE_OTIS && !st.has_quest_items?(TISSUE_BO)) || (npc_id == WEIRD_BUNEI && !st.has_quest_items?(TISSUE_WB))
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
    when GOSTA
      case st.state
      when State::CREATED
        html = pc.level > 37 ? "30916-01.htm" : "30916-00.htm"
      when State::STARTED
        if st.has_quest_items?(TISSUE_BO) && st.has_quest_items?(TISSUE_WB)
          html = "30916-05.htm"
        else
          html = "30916-04.htm"
        end
      when State::COMPLETED
        html = "30916-06.htm"
      end
    when MINEVIA
      case st.state
      when State::STARTED
        if st.has_quest_items?(TISSUE_BO) && st.has_quest_items?(TISSUE_WB)
          html = "30907-02.htm"
        else
          html = "30907-01.htm"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def reward_item(npc_id, st)
    if npc_id == BLADE_OTIS && !st.has_quest_items?(TISSUE_BO)
      st.give_items(TISSUE_BO, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif npc_id == WEIRD_BUNEI && !st.has_quest_items?(TISSUE_WB)
      st.give_items(TISSUE_WB, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end
end
