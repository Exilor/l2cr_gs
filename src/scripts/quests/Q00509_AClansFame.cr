class Scripts::Q00509_AClansFame < Quest
  # NPC
  private VALDIS = 31331

  private REWARD_POINTS = {
    1 => {25290, 8489, 1378}, # Daimon The White-Eyed
    2 => {25293, 8490, 1378}, # Hestia, Guardian Deity Of The Hot Springs
    3 => {25523, 8491, 1070}, # Plague Golem
    4 => {25322, 8492,  782}  # Demon's Agent Falston
  }

  private RAID_BOSS = {
    25290,
    25293,
    25523,
    25322
  }

  def initialize
    super(509, self.class.simple_name, "A Clan's Fame")

    add_start_npc(VALDIS)
    add_talk_id(VALDIS)
    add_kill_id(RAID_BOSS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "31331-0.html"
      st.start_quest
    when "31331-1.html"
      st.set("raid", "1")
      pc.send_packet(RadarControl.new(0, 2, 186304, -43744, -3193))
    when "31331-2.html"
      st.set("raid", "2")
      pc.send_packet(RadarControl.new(0, 2, 134672, -115600, -1216))
    when "31331-3.html"
      st.set("raid", "3")
      pc.send_packet(RadarControl.new(0, 2, 170000, -60000, -3500))
    when "31331-4.html"
      st.set("raid", "4")
      pc.send_packet(RadarControl.new(0, 2, 93296, -75104, -1824))
    when "31331-5.html"
      st.exit_quest(true, true)
    else
      # automatically added
    end


    event
  end

  def on_kill(npc, pc, is_summon)
    unless clan = pc.clan
      return
    end

    st = nil
    if pc.clan_leader?
      st = pc.get_quest_state(name)
    else
      pleader = clan.leader.player_instance
      if pleader && pc.inside_radius?(pleader, 1500, true, false)
        st = pleader.get_quest_state(name)
      end
    end

    if st && st.started?
      raid = st.get_int("raid")
      if tmp = REWARD_POINTS[raid]?
        if npc.id == tmp[0] && !st.has_quest_items?(tmp[1])
          st.reward_items(tmp[1], 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    clan = pc.clan

    case st.state
    when State::CREATED
      if clan.nil? || (!pc.clan_leader? || clan.level < 6)
        html = "31331-0a.htm"
      else
        html = "31331-0b.htm"
      end
    when State::STARTED
      if clan.nil? || !pc.clan_leader?
        st.exit_quest(true)
        return "31331-6.html"
      end

      raid = st.get_int("raid")

      if tmp = REWARD_POINTS[raid]?
        if st.has_quest_items?(tmp[1])
          html = "31331-#{raid}b.html"
          st.play_sound(Sound::ITEMSOUND_QUEST_FANFARE_1)
          st.take_items(tmp[1], -1)
          rep = tmp[2]
          clan.add_reputation_score(rep, true)
          sm = SystemMessage.clan_quest_completed_and_s1_points_gained
          sm.add_int(rep)
          pc.send_packet(sm)
          clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
        else
          html = "31331-#{raid}a.html"
        end
      else
        html = "31331-0.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end