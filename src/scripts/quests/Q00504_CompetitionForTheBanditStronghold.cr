class Scripts::Q00504_CompetitionForTheBanditStronghold < Quest
  # NPC
  private MESSENGER = 35437
  # Monsters
  private MONSTERS = {
    20570 => 6, # Tarlk Bugbear
    20571 => 7, # Tarlk Bugbear Warrior
    20572 => 8, # Tarlk Bugbear High Warrior
    20573 => 9, # Tarlk Basilisk
    20574 => 7  # Elder Tarlk Basilisk
  }
  # Items
  private TARLK_AMULET = 4332
  private CONTEST_CERTIFICATE = 4333
  private TROPHY_OF_ALLIANCE = 5009

  @bandit_stronghold : SiegableHall

  def initialize
    super(504, self.class.simple_name, "Competition for the Bandit Stronghold")

    @bandit_stronghold = ClanHallSiegeManager.get_siegable_hall(35).not_nil!

    add_start_npc(MESSENGER)
    add_talk_id(MESSENGER)
    add_kill_id(MONSTERS.keys)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "35437-02.htm"
      st.start_quest
      st.give_items(CONTEST_CERTIFICATE, 1)
      "35437-02.htm"
    end
  end

  def on_kill(npc, killer, is_summon)
    return unless st = get_quest_state(killer, false)
    unless st.has_quest_items?(CONTEST_CERTIFICATE) && st.started?
      return
    end

    if Rnd.rand(10) < MONSTERS[npc.id]
      st.give_items(TARLK_AMULET, 1)
      if st.get_quest_items_count(TARLK_AMULET) < 30
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    clan = pc.clan

    if !@bandit_stronghold.waiting_battle?
      html = get_htm(pc, "35437-09.html")
      format = "%Y-%m-%d %H:%m:%S"
      html = html.gsub("%nextSiege%", @bandit_stronghold.siege_date.time.to_s(format))
    elsif clan.nil? || clan.level < 4
      html = "35437-04.html"
    elsif !pc.clan_leader?
      html = "35437-05.html"
    elsif clan.hideout_id > 0 || clan.fort_id > 0 || clan.castle_id > 0
      html = "35437-10.html"
    else
      case st.state
      when State::CREATED
        if !@bandit_stronghold.waiting_battle?
          html = get_htm(pc, "35437-03.html")
          format = "%Y-%m-%d %H:%M:%S"
          html = html.gsub("%nextSiege%", @bandit_stronghold.siege_date.time.to_s(format))
        else
          html = "35437-01.htm"
        end
      when State::STARTED
        if st.get_quest_items_count(TARLK_AMULET) < 30
          html = "35437-07.html"
        else
          st.take_items(TARLK_AMULET, 30)
          st.reward_items(TROPHY_OF_ALLIANCE, 1)
          st.exit_quest(true)
          html = "35437-08.html"
        end
      when State::COMPLETED
        html = "35437-07a.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
