module SpawnTable
  extend self
  extend XMLReader

  private SELECT_SPAWNS = "SELECT count, npc_templateid, locx, locy, locz, heading, respawn_delay, respawn_random, loc_id, periodOfDay FROM spawnlist"
  private SELECT_CUSTOM_SPAWNS = "SELECT count, npc_templateid, locx, locy, locz, heading, respawn_delay, respawn_random, loc_id, periodOfDay FROM custom_spawnlist"
  private SPAWN_TABLE = Concurrent::Map(Int32, ISet(L2Spawn)).new

  @@xml_spawn_count = 0

  def load
    unless Config.alt_dev_no_spawns
      timer = Timer.new
      info "Loading NPC spawns..."

      fill_spawn_table(false)
      spawn_count = SPAWN_TABLE.size

      if spawn_count == 0
        warn "No spawns were loaded from the database."
      end

      info { "Loaded #{spawn_count} NPC spawns in #{timer} s." }
      timer.start

      if Config.custom_spawnlist_table
        fill_spawn_table(true)
        info { "Loaded #{SPAWN_TABLE.size - spawn_count} custom NPC spawns in #{timer} s." }
        timer.start
      end

      parse_datapack_directory("spawnlist")
      info { "Loaded #{@@xml_spawn_count} NPC spawns from XML files in #{timer} s." }
    end
  end

  private def fill_spawn_table(is_custom)
    spawn_count = 0

    dat = StatsSet.new

    sql = is_custom ? SELECT_CUSTOM_SPAWNS : SELECT_SPAWNS
    GameDB.each(sql) do |rs|
      npc_id = rs.get_i32("npc_templateid").to_u16!.to_i32
      unless check_template(npc_id)
        next
      end

      dat["npcTemplateid"] = npc_id
      dat["count"] = rs.get_i32("count")
      dat["x"] = rs.get_i32("locx")
      dat["y"] = rs.get_i32("locy")
      dat["z"] = rs.get_i32("locz")
      dat["heading"] = rs.get_i32("heading")
      dat["respawnDelay"] = rs.get_i32("respawn_delay")
      dat["respawnRandom"] = rs.get_i32("respawn_random")
      dat["locId"] = rs.get_i32("loc_id")
      dat["periodOfDay"] = rs.get_i32("periodOfDay")
      dat["isCustomSpawn"] = is_custom

      spawn_count += add_spawn(dat)
    end

    spawn_count
  end

  private def add_spawn(sp : L2Spawn)
    (SPAWN_TABLE[sp.id] ||= Concurrent::Set(L2Spawn).new) << sp
  end

  private def add_spawn(data : StatsSet) : Int32
    add_spawn(data, nil)
  end

  private def add_spawn(data : StatsSet, ai_data : Hash(String, Int32)?) : Int32
    ret = 0

    sp = L2Spawn.new(data.get_i32("npcTemplateid"))
    sp.amount        = data.get_i32("count", 1)
    sp.x             = data.get_i32("x", 0)
    sp.y             = data.get_i32("y", 0)
    sp.z             = data.get_i32("z", 0)
    sp.heading       = data.get_i32("heading", -1)
    sp.set_respawn_delay(data.get_i32("respawnDelay", 0), data.get_i32("respawnRandom", 0))
    sp.location_id   = data.get_i32("locId", 0)
    territory_name   = data.get_string("territoryName", "")
    spawn_name       = data.get_string("spawnName", "")
    sp.custom        = data.get_bool("isCustomSpawn", false)
    unless spawn_name.nil? || spawn_name.empty?
      sp.name = spawn_name
    end

    unless territory_name.empty?
      sp.spawn_territory = ZoneManager.get_spawn_territory(territory_name)
    end

    if ai_data
      NpcPersonalAIData.store_data(sp, ai_data)
    end

    case data.get_i32("periodOfDay", 0)
    when 0 # default
      ret += sp.init
    when 1 # day
      DayNightSpawnManager.add_day_creature(sp)
      ret = 1
    when 2 # night
      DayNightSpawnManager.add_night_creature(sp)
      ret = 1
    end

    add_spawn(sp)

    ret
  end

  private def check_template(npc_id : Int32)
    if template = NpcData[npc_id]?
      !(template.type?("L2SiegeGuard") ||
      template.type?("L2RaidBoss") ||
      (!Config.allow_class_masters && template.type?("L2ClassMaster")))
    else
      error { "Data missing in NPC table for ID #{npc_id}." }
      false
    end
  end

  def get_spawns(npc_id : Int32) : ISet(L2Spawn)
    SPAWN_TABLE.fetch(npc_id, ISet.empty(L2Spawn))
  end

  def get_spawn_count(npc_id : Int32) : Int32
    get_spawns(npc_id).size
  end

  def find_any(npc_id : Int32) : L2Spawn?
    get_spawns(npc_id).first?
  end

  def add_new_spawn(spwn : L2Spawn, store_in_db : Bool)
    add_spawn(spwn)

    if store_in_db
      if spwn.custom? && Config.custom_spawnlist_table
        sql = "INSERT INTO custom_spawnlist(count,npc_templateid,locx,locy,locz,heading,respawn_delay,respawn_random,loc_id) values(?,?,?,?,?,?,?,?,?)"
      else
        sql = "INSERT INTO spawnlist(count,npc_templateid,locx,locy,locz,heading,respawn_delay,respawn_random,loc_id) values(?,?,?,?,?,?,?,?,?)"
      end

      GameDB.exec(
        sql,
        spwn.amount,
        spwn.id,
        spwn.x,
        spwn.y,
        spwn.z,
        spwn.heading,
        spwn.respawn_delay // 1000,
        spwn.respawn_max_delay - spwn.respawn_min_delay,
        spwn.location_id
      )
    end
  end

  def delete_spawn(sp : L2Spawn, update_db : Bool)
    return unless remove_spawn(sp)

    if update_db
      if sp.custom?
        sql = "DELETE FROM custom_spawnlist WHERE locx=? AND locy=? AND locz=? AND npc_templateid=? AND heading=?"
      else
        sql = "DELETE FROM spawnlist WHERE locx=? AND locy=? AND locz=? AND npc_templateid=? AND heading=?"
      end
      begin
        GameDB.exec(
          sql,
          sp.x,
          sp.y,
          sp.z,
          sp.id,
          sp.heading
        )
      rescue e
        error e
      end
    end
  end

  def remove_spawn(sp : L2Spawn) : Bool
    if set = SPAWN_TABLE[sp.id]?
      removed = set.delete(sp)
      if set.empty?
        SPAWN_TABLE.delete(sp.id)
      end

      return !!removed
    end

    false
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |list|
      next unless list["enabled"].casecmp?("true")
      list.find_element("spawn") do |param|
        map = nil
        spawn_name = param["name"]?
        territory_name = nil
        if zone = param["zone"]?
          if ZoneManager.get_spawn_territory(zone)
            territory_name = zone
          end
        end
        param.each_element do |npctag|
          if npctag.name.casecmp?("AIData")
            map ||= {} of String => Int32
            npctag.each_element do |c|
              next if c.name == "#text"
              case c.name
              when "disableRandomAnimation", "disableRandomWalk"
                val = c.text.casecmp?("true") ? 1 : 0
              else
                val = c.text.to_i
              end
              map[c.name] = val
            end
          elsif npctag.name.casecmp?("npc")
            template_id = npctag["id"].to_i

            x = npctag["x"]?.try &.to_i || 0
            y = npctag["y"]?.try &.to_i || 0
            z = npctag["z"]?.try &.to_i || 0

            spawn_info = StatsSet.new
            spawn_info["npcTemplateid"] = template_id
            spawn_info["x"] = x
            spawn_info["y"] = y
            spawn_info["z"] = z
            spawn_info["territoryName"] = territory_name
            spawn_info["spawnName"] = spawn_name

            if val = npctag["heading"]?.try &.to_i
              spawn_info["heading"] = val
            end

            if val = npctag["count"]?.try &.to_i
              spawn_info["count"] = val
            end

            if val = npctag["respawnDelay"]?.try &.to_i
              spawn_info["respawnDelay"] = val
            end

            if val = npctag["spawnRandom"]?.try &.to_i
              spawn_info["respawnRandom"] = val
            end

            if val = npctag["periodOfDay"]?
              if val.casecmp?("day") || val.casecmp?("night")
                spawn_info["periodOfDay"] = val.casecmp?("day") ? 1 : 2
              end
            end

            @@xml_spawn_count += add_spawn(spawn_info, map)
          end
        end
      end
    end
  end
end
