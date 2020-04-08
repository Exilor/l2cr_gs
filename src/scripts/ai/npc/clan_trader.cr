class Scripts::ClanTrader < AbstractNpcAI
  # Npc
  private CLAN_TRADER = {
    32024, # Mulia
    32025  # Ilia
  }
  # Items
  private BLOOD_ALLIANCE = 9911 # Blood Alliance
  private BLOOD_ALLIANCE_COUNT = 1 # Blood Alliance Count
  private BLOOD_OATH = 9910 # Blood Oath
  private BLOOD_OATH_COUNT = 10 # Blood Oath Count
  private KNIGHTS_EPAULETTE = 9912 # Knight's Epaulette
  private KNIGHTS_EPAULETTE_COUNT = 100 # Knight's Epaulette Count

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(CLAN_TRADER)
    add_talk_id(CLAN_TRADER)
    add_first_talk_id(CLAN_TRADER)
  end

  private def give_reputation(npc, pc, count, item_id, item_count)
    if get_quest_items_count(pc, item_id) >= item_count
      take_items(pc, item_id, item_count)
      pc.clan.not_nil!.add_reputation_score(count, true)

      sm = SystemMessage.clan_added_s1s_points_to_reputation_score
      sm.add_int(count)
      pc.send_packet(sm)
      return "#{npc.id}-04.html"
    end

    "#{npc.id}-03.html"
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    npc = npc.not_nil!

    case event
    when "32024.html", "32024-02.html", "32025.html", "32025-02.html"
      event
    when "repinfo"
      pc.clan.not_nil!.level > 4 ? "#{npc.id}-02.html" : "#{npc.id}-05.html"
    when "exchange-ba"
      give_reputation(npc, pc, Config.bloodalliance_points, BLOOD_ALLIANCE, BLOOD_ALLIANCE_COUNT)
    when "exchange-bo"
      give_reputation(npc, pc, Config.bloodoath_points, BLOOD_OATH, BLOOD_OATH_COUNT)
    when "exchange-ke"
      give_reputation(npc, pc, Config.knightsepaulette_points, KNIGHTS_EPAULETTE, KNIGHTS_EPAULETTE_COUNT)
    else
      # automatically added
    end

  end

  def on_first_talk(npc, pc)
    if pc.clan_leader? || pc.has_clan_privilege?(ClanPrivilege::CL_TROOPS_FAME)
      return "#{npc.id}.html"
    end

    "#{npc.id}-01.html"
  end
end