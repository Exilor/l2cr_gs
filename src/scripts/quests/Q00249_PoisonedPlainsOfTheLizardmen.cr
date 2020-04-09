class Scripts::Q00249_PoisonedPlainsOfTheLizardmen < Quest
  # NPCs
  private MOUEN = 30196
  private JOHNNY = 32744

  def initialize
    super(249, self.class.simple_name, "Poisoned Plains of the Lizardmen")

    add_start_npc(MOUEN)
    add_talk_id(MOUEN, JOHNNY)
  end

  def on_adv_event(event, npc, player)
    return unless player
    html = event
    unless st = get_quest_state(player, false)
      return html
    end

    npc = npc.not_nil!

    if npc.id == MOUEN
      if event.casecmp?("30196-03.htm")
        st.start_quest
      end
    elsif npc.id == JOHNNY && event.casecmp?("32744-03.htm")
      st.give_adena(83056, true)
      st.add_exp_and_sp(477496, 58743)
      st.exit_quest(false, true)
    end

    html
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    if npc.id == MOUEN
      case st.state
      when State::CREATED
        html = player.level >= 82 ? "30196-01.htm" : "30196-00.htm"
      when State::STARTED
        if st.cond?(1)
          html = "30196-04.htm"
        end
      when State::COMPLETED
        html = "30196-05.htm"
      else
        # [automatically added else]
      end

    elsif npc.id == JOHNNY
      if st.cond?(1)
        html = "32744-01.htm"
      elsif st.completed?
        html = "32744-04.htm"
      end
    end

    html || get_no_quest_msg(player)
  end
end
