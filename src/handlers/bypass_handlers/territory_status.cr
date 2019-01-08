module BypassHandler::TerritoryStatus
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    return false unless npc = target.as?(L2Npc)

    html = NpcHtmlMessage.new(npc.l2id)

    if npc.castle.owner_id > 0
      html.set_file(pc, "data/html/territorystatus.htm")
      clan = ClanTable.get_clan!(npc.castle.owner_id)
      html["%clanname%"] = clan.name
      html["%clanleadername%"] = clan.leader_name
    else
      html.set_file(pc, "data/html/territorynoclan.htm")
    end

    html["%castlename%"] = npc.castle.name
    html["%taxpercent%"] = npc.castle.tax_percent
    html["%objectId%"] = npc.l2id

    if npc.castle.residence_id > 6
      html["%territory%"] = "The Kingdom of Elmore"
    else
      html["%territory%"] = "The Kingdom of Aden"
    end

    pc.send_packet(html)
    true
  end

  def commands
    {"TerritoryStatus"}
  end
end
