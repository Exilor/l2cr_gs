class Scripts::Q00508_AClansReputation < Quest
  # NPC
  private SIR_ERIC_RODEMAI = 30868

  private REWARD_POINTS = {
    1 => {25252,  8277, 560}, # Palibati Queen Themis
    2 => {25478, 14883, 584}, # Shilen's Priest Hisilrome
    3 => {25255,  8280, 602}, # Gargoyle Lord Tiphon
    4 => {25245,  8281, 784}, # Last Lesser Giant Glaki
    5 => {25051,  8282, 558}, # Rahha
    6 => {25524,  8494, 768}  # Flamestone Giant
  }

  private RAID_BOSS = {
    25252,
    25478,
    25255,
    25245,
    25051,
    25524
  }

  def initialize
    super(508, self.class.simple_name, "A Clan's Reputation")

    add_start_npc(SIR_ERIC_RODEMAI)
    add_talk_id(SIR_ERIC_RODEMAI)
    add_kill_id(RAID_BOSS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30868-0.html"
      st.start_quest
    when "30868-1.html"
      st.set("raid", "1")
      pc.send_packet(RadarControl.new(0, 2, 192376, 22087, -3608))
    when "30868-2.html"
      st.set("raid", "2")
      pc.send_packet(RadarControl.new(0, 2, 168288, 28368, -3632))
    when "30868-3.html"
      st.set("raid", "3")
      pc.send_packet(RadarControl.new(0, 2, 170048, -24896, -3440))
    when "30868-4.html"
      st.set("raid", "4")
      pc.send_packet(RadarControl.new(0, 2, 188809, 47780, -5968))
    when "30868-5.html"
      st.set("raid", "5")
      pc.send_packet(RadarControl.new(0, 2, 117760, -9072, -3264))
    when "30868-6.html"
      st.set("raid", "6")
      pc.send_packet(RadarControl.new(0, 2, 144600, -5500, -4100))
    when "30868-7.html"
      st.exit_quest(true, true)
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    unless clan = pc.clan?
      return
    end

    if pc.clan_leader?
      st = pc.get_quest_state(name)
    else
      pleader = clan.leader.player_instance?
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
    clan = pc.clan?

    case st.state
    when State::CREATED
      if clan.nil? || (!pc.clan_leader? || clan.level < 5)
        html = "30868-0a.htm"
      else
        html = "30868-0b.htm"
      end
    when State::STARTED
      if clan.nil? || !pc.clan_leader?
        st.exit_quest(true)
        return "30868-8.html"
      end

      raid = st.get_int("raid")

      if tmp = REWARD_POINTS[raid]?
        if st.has_quest_items?(tmp[1])
          html = "30868-#{raid}b.html"
          st.play_sound(Sound::ITEMSOUND_QUEST_FANFARE_1)
          st.take_items(tmp[1], -1)
          rep = tmp[2]
          clan.add_reputation_score(rep, true)
          sm = SystemMessage.clan_quest_completed_and_s1_points_gained
          sm.add_int(rep)
          pc.send_packet(sm)
          clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
        else
          html = "30868-#{raid}a.html"
        end
      else
        html = "30868-0.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
