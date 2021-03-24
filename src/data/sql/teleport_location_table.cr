require "../../models/l2_teleport_location"

module TeleportLocationTable
  extend self
  include Loggable

  private TELEPORTS = {} of Int32 => L2TeleportLocation

  def load
    TELEPORTS.clear

    timer = Timer.new
    count = load("teleport")
    info { "Loaded #{count} teleport locations in #{timer} s." }

    if Config.custom_teleport_table
      timer.start
      count = load("custom_teleport")
      info { "Loaded #{count} custom teleport locations in #{timer} s." }
    end
  end

  def [](id : Int) : L2TeleportLocation
    TELEPORTS.fetch(id) { raise "No teleport location with id #{id}" }
  end

  def []?(id : Int) : L2TeleportLocation?
    TELEPORTS[id]?
  end

  private def load(table) : Int32
    count = 0
    sql = "SELECT id, loc_x, loc_y, loc_z, price, fornoble, itemId FROM "
    GameDB.each(sql + table) do |rs|
      id = rs.get_i32(:"id")
      x, y, z = rs.get_i32(:"loc_x"), rs.get_i32(:"loc_y"), rs.get_i32(:"loc_z")
      price = rs.get_i32(:"price")
      for_noble = rs.get_bool(:"fornoble")
      item_id = rs.get_i32(:"itemId")

      tp = L2TeleportLocation.new(id, x, y, z, price, item_id, for_noble)
      TELEPORTS[tp.tele_id] = tp
      count &+= 1
    end
    count
  end
end
