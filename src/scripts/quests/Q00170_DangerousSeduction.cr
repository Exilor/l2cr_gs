class Scripts::Q00170_DangerousSeduction < Quest
  # NPC
  private VELLIOR = 30305
  # Monster
  private MERKENIS = 27022
  # Item
  private NIGHTMARE_CRYSTAL = 1046
  # Misc
  private MIN_LEVEL = 21

  def initialize
    super(170, self.class.simple_name, "Dangerous Seduction")

    add_start_npc(VELLIOR)
    add_talk_id(VELLIOR)
    add_kill_id(MERKENIS)
    register_quest_items(NIGHTMARE_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    if event.casecmp?("30305-04.htm")
      st.start_quest
      return event
    end

    nil
  end

  def on_kill(npc, player, is_summon)
    st = get_quest_state(player, false)
    if st && st.cond?(1)
      st.set_cond(2, true)
      st.give_items(NIGHTMARE_CRYSTAL, 1)
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::SEND_MY_SOUL_TO_LICH_KING_ICARUS))
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      if player.race.dark_elf?
        if player.level >= MIN_LEVEL
          html = "30305-01.htm"
        else
          html = "30305-02.htm"
        end
      else
        html = "30305-03.htm"
      end
    when State::STARTED
      if st.cond?(1)
        html = "30305-05.html"
      else
        st.give_adena(102_680, true)
        st.add_exp_and_sp(38_607, 4018)
        st.exit_quest(false, true)
        html = "30305-06.html"
      end
    when State::COMPLETED
      html = get_already_completed_msg(player)
    end

    html || get_no_quest_msg(player)
  end
end
