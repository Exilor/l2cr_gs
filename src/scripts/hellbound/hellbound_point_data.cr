module HellboundPointData
  extend self
  extend XMLReader

  private record HellboundPoint, points : Int32, min_lvl : Int32,
    max_lvl : Int32, lowest_trust_limit : Int32

  private POINTS_INFO = {} of Int32 => HellboundPoint

  def load
    POINTS_INFO.clear
    parse_datapack_file("scripts/hellbound/hellboundTrustPoints.xml")
    info { "Loaded #{POINTS_INFO.size} trust point reward data." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |list|
      list.each_element do |d|
        parse_point(d)
      end
    end
  end

  private def parse_point(d)
    unless d.name == "npc"
      return
    end

    unless tmp = d["id"]?
      error "Missing NPC id."
      return
    end

    npc_id = tmp.to_i

    unless tmp = d["points"]?
      error { "Missing reward point info for NPC with id #{npc_id}." }
      return
    end

    points = tmp.to_i

    unless tmp = d["minHellboundLvl"]?
      error { "Missing minHellboundLvl info for NPC with id #{npc_id}." }
      return
    end

    min_hb_lvl = tmp.to_i

    unless tmp = d["maxHellboundLvl"]?
      error { "Missing maxHellboundLvl info for NPC with id #{npc_id}." }
      return
    end

    max_hb_lvl = tmp.to_i

    if tmp = d["lowestTrustLimit"]?
      lowest_trust_limit = tmp.to_i
    end

    POINTS_INFO[npc_id] = HellboundPoint.new(
      points,
      min_hb_lvl,
      max_hb_lvl,
      lowest_trust_limit || 0
    )
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
