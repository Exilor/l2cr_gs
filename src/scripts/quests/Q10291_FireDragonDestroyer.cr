class Scripts::Q10291_FireDragonDestroyer < Quest
  # NPC
  private KLEIN = 31540
  # Monster
  private VALAKAS = 29028
  # Items
  private FLOATING_STONE = 7267
  private POOR_NECKLACE = 15524
  private VALOR_NECKLACE = 15525

  private VALAKAS_SLAYER_CIRCLET = 8567

  def initialize
    super(10291, self.class.simple_name, "Fire Dragon Destroyer")

    add_start_npc(KLEIN)
    add_talk_id(KLEIN)
    add_kill_id(VALAKAS)
    register_quest_items(POOR_NECKLACE, VALOR_NECKLACE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event == "31540-05.htm"
      st.start_quest
      st.give_items(POOR_NECKLACE, 1)
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    unless party = pc.party
      return super
    end

    # Rewards go only to command channel, not to a single party or player.

    if cc = party.command_channel
      cc.each do |p|
        if Util.in_range?(8000, npc, p, false)
          st = get_quest_state(p, false)

          if st && st.cond?(1) && st.has_quest_items?(POOR_NECKLACE)
            st.take_items(POOR_NECKLACE, -1)
            st.give_items(VALOR_NECKLACE, 1)
            st.set_cond(2, true)
          end
        end
      end
    else
      party.each do |p|
        if Util.in_range?(8000, npc, p, false)
          if st = get_quest_state(p, false)
            if st.cond?(1) && st.has_quest_items?(POOR_NECKLACE)
              st.take_items(POOR_NECKLACE, -1)
              st.give_items(VALOR_NECKLACE, 1)
              st.set_cond(2, true)
            end
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level < 83
        html = "31540-00.htm"
      else
        if st.has_quest_items?(FLOATING_STONE)
          html = "31540-02.htm"
        else
          html = "31540-01.htm"
        end
      end
    when State::STARTED
      if st.cond?(1)
        if st.has_quest_items?(POOR_NECKLACE)
          html = "31540-06.html"
        else
          st.give_items(POOR_NECKLACE, 1)
          html = "31540-07.html"
        end
      elsif st.cond?(2) && st.has_quest_items?(VALOR_NECKLACE)
        html = "31540-08.html"
        st.give_adena(126_549, true)
        st.add_exp_and_sp(717_291, 77_397)
        st.give_items(VALAKAS_SLAYER_CIRCLET, 1)
        st.exit_quest(false, true)
      end
    when State::COMPLETED
      html = "31540-09.html"
    end

    html || get_no_quest_msg(pc)
  end
end
