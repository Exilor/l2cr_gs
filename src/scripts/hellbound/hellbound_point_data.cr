module HellboundPointData
  extend self
  extend XMLReader

  private record HellboundPoint, points : Int32, min_lvl : Int32,
    max_lvl : Int32, lowest_trust_limit : Int32

  private POINTS_INFO = {} of Int32 => HellboundPoint

  def load
    POINTS_INFO.clear
    parse_datapack_file("hellbound/hellboundTrustPoints.xml")
    info { "Loaded #{POINTS_INFO.size} trust point reward data." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |list|
      find_element(list, "npc") { |d| parse_point(d) }
    end
  end

  private def parse_point(d)
    unless npc_id = parse_int(d, "id", nil)
      error "Missing NPC id."
      return
    end

    unless points = parse_int(d, "points", nil)
      error { "Missing reward point info for NPC with id #{npc_id}." }
      return
    end

    unless min_hb_lvl = parse_int(d, "minHellboundLvl", nil)
      error { "Missing minHellboundLvl info for NPC with id #{npc_id}." }
      return
    end

    unless max_hb_lvl = parse_int(d, "maxHellboundLvl", nil)
      error { "Missing maxHellboundLvl info for NPC with id #{npc_id}." }
      return
    end

    lowest_trust_limit = parse_int(d, "lowestTrustLimit", 0)

    hp = HellboundPoint.new(points, min_hb_lvl, max_hb_lvl, lowest_trust_limit)
    POINTS_INFO[npc_id] = hp
  end

  def points_info : Hash(Int32, HellboundPoint)
    POINTS_INFO
  end

  def get_points_amount(npc_id : Int32) : Int32
    POINTS_INFO[npc_id].points
  end

  def get_min_hb_lvl(npc_id : Int32) : Int32
    POINTS_INFO[npc_id].min_lvl
  end

  def get_max_hb_lvl(npc_id : Int32) : Int32
    POINTS_INFO[npc_id].max_lvl
  end

  def get_lowest_trust_limit(npc_id : Int32) : Int32
    POINTS_INFO[npc_id].lowest_trust_limit
  end
end
