class NpcAI::FortressSiegeManager < AbstractNpcAI
  # NPCs
  private MANAGERS = {
    35659, # Shanty Fortress
    35690, # Southern Fortress
    35728, # Hive Fortress
    35759, # Valley Fortress
    35797, # Ivory Fortress
    35828, # Narsell Fortress
    35859, # Bayou Fortress
    35897, # White Sands Fortress
    35928, # Borderland Fortress
    35966, # Swamp Fortress
    36004, # Archaic Fortress
    36035, # Floran Fortress
    36073, # Cloud Mountain
    36111, # Tanor Fortress
    36142, # Dragonspine Fortress
    36173, # Antharas's Fortress
    36211, # Western Fortress
    36249, # Hunter's Fortress
    36287, # Aaru Fortress
    36318, # Demon Fortress
    36356  # Monastic Fortress
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(MANAGERS)
    add_talk_id(MANAGERS)
    add_first_talk_id(MANAGERS)
  end

  def on_adv_event(event, npc, player)
    return unless npc && player

    case event
    when "FortressSiegeManager-11.html", "FortressSiegeManager-13.html",
         "FortressSiegeManager-14.html", "FortressSiegeManager-15.html",
         "FortressSiegeManager-16.html"
      return htmltext = event
    when "register"
      clan = player.clan?
      if clan.nil?
        htmltext = "FortressSiegeManager-02.html"
      else
        fortress = npc.fort
        castle = npc.castle

        if clan.fort_id == fortress.residence_id
          html = NpcHtmlMessage.new(npc.l2id)
          html.html = get_htm(player, "FortressSiegeManager-12.html")
          html["%clanName%"] = fortress.owner_clan.name
          return html.html
        elsif !player.has_clan_privilege?(ClanPrivilege::CS_MANAGE_SIEGE)
          htmltext = "FortressSiegeManager-10.html"
        elsif clan.level < FortSiegeManager.siege_clan_min_level
          htmltext = "FortressSiegeManager-04.html"
        elsif player.clan.castle_id == castle.residence_id && fortress.fort_state == 2
          htmltext = "FortressSiegeManager-18.html"
        elsif clan.castle_id != 0 && clan.castle_id != castle.residence_id && FortSiegeManager.can_register_just_territory?
          htmltext = "FortressSiegeManager-17.html"
        elsif fortress.time_until_rebel_army > 0 && fortress.time_until_rebel_army <= 7200
          htmltext = "FortressSiegeManager-19.html"
        else
          case npc.fort.siege.add_attacker(player, true)
          when 1
            htmltext = "FortressSiegeManager-03.html"
          when 2
            htmltext = "FortressSiegeManager-07.html"
          when 3
            htmltext = "FortressSiegeManager-06.html"
          when 4
            sm = SystemMessage.registered_to_s1_fortress_battle
            sm.add_string(npc.fort.name)
            player.send_packet(sm)
            htmltext = "FortressSiegeManager-05.html"
          end
        end
      end
    when "cancel"
      clan = player.clan?
      if clan.nil?
        htmltext = "FortressSiegeManager-02.html"
      else
        fortress = npc.fort

        if clan.fort_id == fortress.residence_id
          html = NpcHtmlMessage.new(npc.l2id)
          html.html = get_htm(player, "FortressSiegeManager-12.html")
          html["%clanName%"] = fortress.owner_clan.name
          return html.html
        elsif !player.has_clan_privilege?(ClanPrivilege::CS_MANAGE_SIEGE)
          htmltext = "FortressSiegeManager-10.html"
        elsif !FortSiegeManager.registered?(clan, fortress.residence_id)
          htmltext = "FortressSiegeManager-09.html"
        else
          fortress.siege.remove_attacker(clan)
          htmltext = "FortressSiegeManager-08.html"
        end
      end
    when "warInfo"
      if npc.fort.siege.attacker_clans.empty?
        htmltext = "FortressSiegeManager-20.html"
      else
        htmltext = "FortressSiegeManager-21.html"
      end
    end

    htmltext
  end

  def on_first_talk(npc, player)
    fortress = npc.fort
    owner_clan = fortress.owner_clan?
    fort_owner = owner_clan ? owner_clan.id : 0
    if fort_owner == 0
      return "FortressSiegeManager.html"
    end
    html = NpcHtmlMessage.new(npc.l2id)
    html.html = get_htm(player, "FortressSiegeManager-01.html")
    html["%clanName%"] = fortress.owner_clan.name
    html["%objectId%"] = npc.l2id

    html.html
  end
end
