class Scripts::Lekon < AbstractNpcAI
  # NPCs
  private LEKON = 32557
  # Items
  private LICENCE = 13559 # Airship Summon License
  private STONE = 13277 # Energy Star Stone
  # Misc
  private MIN_CLAN_LV = 5
  private STONE_COUNT = 10

  def initialize
    super(self.class.simple_name, "gracia/AI/NPC")

    add_first_talk_id(LEKON)
    add_talk_id(LEKON)
    add_start_npc(LEKON)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "32557-01.html"
      html = event
    when "licence"
      pc = pc.not_nil!

      clan = pc.clan
      if clan.nil? || (!pc.clan_leader? || clan.level < MIN_CLAN_LV)
        html = "32557-02.html"
      elsif has_at_least_one_quest_item?(pc, LICENCE)
        html = "32557-04.html"
      elsif AirshipManager.has_airship_license?(clan.id)
        pc.send_packet(SystemMessageId::THE_AIRSHIP_SUMMON_LICENSE_ALREADY_ACQUIRED)
      elsif get_quest_items_count(pc, STONE) >= STONE_COUNT
        take_items(pc, STONE, STONE_COUNT)
        give_items(pc, LICENCE, 1)
      else
        html = "32557-03.html"
      end
    else
      # automatically added
    end


    html
  end
end