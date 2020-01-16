class Scripts::Q00655_AGrandPlanForTamingWildBeasts < Quest
  # NPCs
  private MESSENGER = 35627
  # Items
  private CRYSTAL_OF_PURITY = 8084
  private TRAINER_LICENSE = 8293
  # Misc
  private REQUIRED_CRYSTAL_COUNT = 10
  private REQUIRED_CLAN_LEVEL = 4
  private MINUTES_TO_SIEGE = 3600
  private PATH_TO_HTML = "data/scripts/conquerablehalls/flagwar/WildBeastReserve/messenger_initial.htm"

  def initialize
    super(655, self.class.simple_name, "A Grand Plan for Taming Wild Beasts")

    add_start_npc(MESSENGER)
    add_talk_id(MESSENGER)
    register_quest_items(CRYSTAL_OF_PURITY, TRAINER_LICENSE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    html = nil
    clan = pc.clan
    minutes_to_siege = minutes_to_siege()
    case event
    when "35627-06.html"
      if qs.created?
        if clan && clan.level >= REQUIRED_CLAN_LEVEL && clan.fort_id == 0
          if pc.clan_leader? && minutes_to_siege > 0
            if minutes_to_siege < MINUTES_TO_SIEGE
              qs.start_quest
              html = event
            end
          end
        end
      end
    when "35627-06a.html"
      html = event
    when "35627-11.html"
      if minutes_to_siege > 0 && minutes_to_siege < MINUTES_TO_SIEGE
        html = HtmCache.get_htm(pc, PATH_TO_HTML)
      else
        html = get_htm(pc, event)
        html = html.sub("%next_siege%", siege_date)
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    html = get_no_quest_msg(pc)
    minutes_to_siege = minutes_to_siege()

    if qs.created?
      unless clan = pc.clan
        return html
      end

      if minutes_to_siege > 0 && minutes_to_siege < MINUTES_TO_SIEGE
        if pc.clan_leader?
          if clan.fort_id == 0
            if clan.level >= REQUIRED_CLAN_LEVEL
              html = "35627-01.html"
            else
              html = "35627-03.html"
            end
          else
            html = "35627-04.html"
          end
        else
          if clan.fort_id == ClanHallSiegeEngine::BEAST_FARM && minutes_to_siege > 0 && minutes_to_siege < MINUTES_TO_SIEGE
            html = HtmCache.get_htm(pc, PATH_TO_HTML)
          else
            html = "35627-05.html"
          end
        end
      else
        html = get_htm(pc, "35627-02.html")
        html = html.sub("%next_siege%", siege_date)
      end
    else
      if minutes_to_siege < 0 || minutes_to_siege > MINUTES_TO_SIEGE
        take_items(pc, TRAINER_LICENSE, -1)
        take_items(pc, CRYSTAL_OF_PURITY, -1)
        qs.exit_quest(true, true)
        html = "35627-07.html"
      else
        if has_quest_items?(pc, TRAINER_LICENSE)
          html = "35627-09.html"
        else
          if get_quest_items_count(pc, CRYSTAL_OF_PURITY) < REQUIRED_CRYSTAL_COUNT
            html = "35627-08.html"
          else
            give_items(pc, TRAINER_LICENSE, 1)
            take_items(pc, CRYSTAL_OF_PURITY, -1)
            qs.set_cond(3, true)
            html = "35627-10.html"
          end
        end
      end
    end

    html
  end

  private def siege_date
    if hall = ClanHallSiegeManager.get_siegable_hall(ClanHallSiegeEngine::BEAST_FARM)
      format = "%Y-%m-%d %H:%M:%S"
      hall.siege_date.time.to_s(format)
    end

    "Error in date."
  end

  private def minutes_to_siege
    if hall = ClanHallSiegeManager.get_siegable_hall(ClanHallSiegeEngine::BEAST_FARM)
      return (hall.next_siege_time - Time.ms) / 3600
    end

    -1
  end

  def self.reward(pc, npc)
    clan = pc.clan
    leader = clan ? clan.leader.player_instance : nil
    if leader
      if qs655 = leader.get_quest_state(self.class.simple_name)
        if get_quest_items_count(leader, CRYSTAL_OF_PURITY) < REQUIRED_CRYSTAL_COUNT
          if Util.in_range?(2000, leader, npc, true)
            if leader.level >= REQUIRED_CLAN_LEVEL
              give_items(leader, CRYSTAL_OF_PURITY, 1)
            end

            if get_quest_items_count(leader, CRYSTAL_OF_PURITY) >= 9
              qs655.set_cond(2, true)
            else
              play_sound(leader, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    end
  end
end
