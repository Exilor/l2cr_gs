require "../../../models/l2_territory"

module TerritoryTable
  extend self
  extend Loggable

  private TERRITORIES = {} of Int32 => L2Territory

  def load
    TERRITORIES.clear

    sql = "SELECT * FROM locations WHERE loc_id>0"
    GameDB.each(sql) do |rs|
      terr_id = rs.get_i32("loc_id")
      unless terr = TERRITORIES[terr_id]?
        terr = L2Territory.new(terr_id)
        TERRITORIES[terr_id] = terr
      end
      terr.add(
        rs.get_i32("loc_x"),
        rs.get_i32("loc_y"),
        rs.get_i32("loc_zmin"),
        rs.get_i32("loc_zmax"),
        rs.get_i32("proc")
      )
    end

    info "Loaded #{TERRITORIES.size} territories."

    if TERRITORIES.empty?
      warn "No territories were loaded."
    end
  end

  def get_random_point(terr : Int) : Location?
    TERRITORIES[terr].random_point
  end

  def get_proc_max(terr : Int) : Int32
    TERRITORIES[terr].proc_max
  end
end
