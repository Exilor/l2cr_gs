class Scripts::Q00510_AClansPrestige < Quest
  # NPC
  private VALDIS = 31331
  # Quest Item
  private TYRANNOSAURUS_CLAW = 8767

  private MOBS = {
    22215,
    22216,
    22217
  }

  def initialize
    super(510, self.class.simple_name, "A Clan's Prestige")

    add_start_npc(VALDIS)
    add_talk_id(VALDIS)
    add_kill_id(MOBS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "31331-3.html"
      st.start_quest
    when "31331-6.html"
      st.exit_quest(true, true)
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    unless clan = pc.clan
      return
    end

    if pc.clan_leader?
      st = get_quest_state(pc, false)
    else
      pleader = clan.leader.player_instance
      if pleader && pc.inside_radius?(pleader, 1500, true, false)
        st = get_quest_state(pleader, false)
      end
    end

    if st && st.started?
      st.reward_items(TYRANNOSAURUS_CLAW, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    clan = pc.clan

    case st.state
    when State::CREATED
      if clan.nil? || (!pc.clan_leader? || clan.level < 5)
        html = "31331-0.htm"
      else
        html = "31331-1.htm"
      end
    when State::STARTED
      if clan.nil? || !pc.clan_leader?
        st.exit_quest(true)
        return "31331-8.html"
      end

      if !st.has_quest_items?(TYRANNOSAURUS_CLAW)
        html = "31331-4.html"
      else
        count = st.get_quest_items_count(TYRANNOSAURUS_CLAW)
        reward = count < 10 ? 30 * count : 59 + (30 * count)
        st.play_sound(Sound::ITEMSOUND_QUEST_FANFARE_1)
        st.take_items(TYRANNOSAURUS_CLAW, -1)
        clan.add_reputation_score(reward, true)
        sm = SystemMessage.clan_quest_completed_and_s1_points_gained
        sm.add_int(reward)
        pc.send_packet(sm)
        clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
        html = "31331-7.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
