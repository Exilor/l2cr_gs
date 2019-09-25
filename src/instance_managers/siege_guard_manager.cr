require "./merc_ticket_manager"

struct SiegeGuardManager
  include Loggable

  getter siege_guard_spawn = [] of L2Spawn

  getter_initializer castle : Castle

  def add_siege_guard(pc : L2PcInstance, npc_id : Int32)
    add_siege_guard(*pc.xyz, pc.heading, npc_id)
  end

  def add_siege_guard(x : Int32, y : Int32, z : Int32, heading : Int32, npc_id : Int32)
    save_siege_guard(x, y, z, heading, npc_id, 0)
  end

  def hire_merc(pc : L2PcInstance, npc_id : Int32)
    hire_merc(*pc.xyz, pc.heading, npc_id)
  end

  def hire_merc(x : Int32, y : Int32, z : Int32, heading : Int32, npc_id : Int32)
    save_siege_guard(x, y, z, heading, npc_id, 1)
  end

  def remove_merc(x : Int32, y : Int32, z : Int32, npc_id : Int32)
    sql = "DELETE FROM castle_siege_guards Where npcId = ? AND x = ? AND y = ? AND z = ? AND isHired = 1"
    GameDB.exec(sql, npc_id, x, y, z)
  rescue e
    error e
  end

  def remove_mercs
    sql = "DELETE FROM castle_siege_guards WHERE castleId = ? AND isHired = 1"
    GameDB.exec(sql, castle.residence_id)
  rescue e
    error e
  end

  def spawn_siege_guard
    hired_count = 0
    hired_max = MercTicketManager.get_max_allowed_merc(@castle.residence_id)
    hired = castle.owner_id > 0

    load_siege_guard

    @siege_guard_spawn.each do |sp|
      sp.init
      if hired
        sp.stop_respawn
        hired_count += 1
        if hired_count > hired_max
          return
        end
      end
    end
  rescue e
    error e
  end

  def unspawn_siege_guard
    @siege_guard_spawn.each do |sp|
      if last = sp.last_spawn
        sp.stop_respawn
        last.do_die(last)
      end
    end

    @siege_guard_spawn.clear
  end

  private def load_siege_guard
    sql = "SELECT * FROM castle_siege_guards Where castleId = ? And isHired = ?"
    if castle.owner_id > 0
      arg = 1
    else
      arg = 0
    end

    GameDB.each(sql, arg) do |rs|
      npc_id = rs.get_i32("npcId").to_u16!.to_i32
      sp = L2Spawn.new(npc_id)
      sp.amount = 1
      sp.x = rs.get_i32("x")
      sp.y = rs.get_i32("y")
      sp.z = rs.get_i32("z")
      sp.heading = rs.get_i32("heading")
      sp.respawn_delay = rs.get_i32("respawnDelay")
      sp.location_id = 0

      @siege_guard_spawn << sp
    end
  rescue e
    error e
  end

  private def save_siege_guard(x : Int32, y : Int32, z : Int32, heading : Int32, npc_id : Int32, is_hire : Int32)
    sql = "INSERT INTO castle_siege_guards (castleId, npcId, x, y, z, heading, respawnDelay, isHired) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    GameDB.exec(
      sql,
      castle.residence_id,
      npc_id,
      x,
      y,
      z,
      heading,
      is_hire == 1 ? 0 : 600,
      is_hire
    )
  rescue e
    error e
  end
end
