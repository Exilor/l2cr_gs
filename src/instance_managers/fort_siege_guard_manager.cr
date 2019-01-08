class FortSiegeGuardManager
  include Loggable

  @siege_guards = {} of Int32 => Array(L2Spawn)

  getter_initializer fort: Fort

  def spawn_siege_guard
    if monster_list = @siege_guards[fort.residence_id]?
      monster_list.each do |sp|
        sp.do_spawn
        if sp.respawn_delay == 0
          sp.stop_respawn
        else
          sp.start_respawn
        end
      end
    end
  rescue e
    error e
  end

  def unspawn_siege_guard
    if monster_list = @siege_guards[fort.residence_id]?
      monster_list.each do |sp|
        sp.stop_respawn
        if last = sp.last_spawn
          last.do_die(last)
        end
      end
    end
  rescue e
    error e
  end

  def load_siege_guard
    @siege_guards.clear

    siege_guard_spawns = [] of L2Spawn
    sql = "SELECT npcId, x, y, z, heading, respawnDelay FROM fort_siege_guards WHERE fortId = ?"
    GameDB.each(sql, fort.residence_id) do |rs|

      npc_id = rs.get_i32("npcId").to_u16.to_i32
      sp = L2Spawn.new(npc_id)
      sp.amount = 1
      sp.x = rs.get_i32("x")
      sp.y = rs.get_i32("y")
      sp.z = rs.get_i32("z")
      sp.heading = rs.get_i32("heading")
      sp.respawn_delay = rs.get_i32("respawnDelay")
      sp.location_id = 0

      siege_guard_spawns << sp
    end

    @siege_guards[fort.residence_id] = siege_guard_spawns
  rescue e
    error e
  end

  def siege_guard_spawn
    @siege_guards
  end
end
