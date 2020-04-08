require "../models/zones/l2_zone_type"
require "../models/zones/form/*"
require "../models/zones/type/*"

module ZoneManager
  extend self
  extend XMLReader

  private SETTINGS = {} of String => AbstractZoneSettings
  private CLASS_ZONES = {} of L2ZoneType.class => Hash(Int32, L2ZoneType)
  private SPAWN_TERRITORIES = {} of String => NpcSpawnTerritory

  @@last_dynamic_id = 300_000

  class_getter(debug_items) { [] of L2ItemInstance }

  def load
    debug "Loading zones..."
    timer = Timer.new
    CLASS_ZONES.clear
    SPAWN_TERRITORIES.clear
    parse_datapack_directory("zones", false)
    info { "Loaded #{CLASS_ZONES.size} zone classes and #{size} zones in #{timer} s." }
    timer.start
    parse_datapack_directory("zones/npcSpawnTerritories")
    info { "Loaded #{SPAWN_TERRITORIES.size} NPC spawn territories in #{timer} s." }
  end

  def reload
    count = 0
    CLASS_ZONES.each_value do |hash|
      hash.each_value do |zone|
        if tmp = zone.settings
          SETTINGS[zone.name.not_nil!] = tmp
        end
      end
    end

    L2World.world_regions.each do |reg|
      reg.each do |r|
        r.zones.clear
        count += 1
      end
    end

    GrandBossManager.zones.clear

    info { "Removed zones in #{count} regions." }

    load

    L2World.objects.each do |obj|
      if obj.is_a?(L2Character)
        obj.revalidate_zone(true)
      end
    end

    SETTINGS.clear
  end

  private def parse_document(doc, file)
    rs = [] of {Int32, Int32}

    doc.find_element("list") do |n|
      next if n["enabled"]? && !Bool.new(n["enabled"])

      n.find_element("zone") do |d|
        unless zone_type = d["type"]
          warn { "Missing type for zone in file #{file}." }
          next
        end

        if temp = d["id"]?
          zone_id = temp.to_i
        else
          if zone_type.casecmp?("NpcSpawnTerritory")
            zone_id = 0
          else
            zone_id = @@last_dynamic_id
            @@last_dynamic_id += 1
          end
        end

        zone_name = d["name"]

        if zone_type.casecmp?("NpcSpawnTerritory")
          if zone_name.nil?
            warn { "Missing name for NpcSpawnTerritory in file #{file}." }
            next
          elsif SPAWN_TERRITORIES.has_key?(zone_name)
            warn { "Name \"#{zone_name}\" already used for another zone, check file #{file}." }
            next
          end
        end

        min_z = d["minZ"].to_i
        max_z = d["maxZ"].to_i

        zone_type = d["type"]
        zone_shape = d["shape"]

        d.find_element("node") do |cd|
          rs << {cd["X"].to_i, cd["Y"].to_i}
        end

        coords = rs.clone
        rs.clear

        case zone_shape.casecmp
        when "Cuboid"
          if coords.size == 2
            zone_form = ZoneCuboid.new(coords[0][0], coords[1][0], coords[0][1], coords[1][1], min_z, max_z)
          else
            warn { "Missing cuboid vertex for zone #{zone_id} in file #{file}." }
            next
          end
        when "NPoly"
          if coords.size > 2
            ax = Slice(Int32).new(coords.size)
            ay = Slice(Int32).new(coords.size)
            coords.each_with_index do |coord, i|
              ax[i], ay[i] = coord
            end
            zone_form = ZoneNPoly.new(ax, ay, min_z, max_z)
          else
            warn { "Bad data for ZoneNPoly zone #{zone_id} in file #{file}." }
            next
          end
        when "Cylinder"
          zone_rad = d["rad"].to_i
          if coords.size == 1 && zone_rad > 0
            zone_form = ZoneCylinder.new(*coords[0], min_z, max_z, zone_rad)
          else
            warn { "Bad data for ZoneCylinder zone #{zone_id} in file #{file}." }
            next
          end
        else
          warn { "Unknown shape \"#{zone_shape}\" for zone in file #{file}." }
          next
        end

        if zone_type.casecmp?("NpcSpawnTerritory")
          SPAWN_TERRITORIES[zone_name] = NpcSpawnTerritory.new(zone_name, zone_form)
          next
        end

        # constructor =
        # case constructor_name
        # when "L2ArenaZone" then L2ArenaZone
        # when "L2BossZone" then L2BossZone
        # when "L2CastleZone" then L2CastleZone
        # when "L2ClanHallZone" then L2ClanHallZone
        # when "L2ConditionZone" then L2ConditionZone
        # when "L2DamageZone" then L2DamageZone
        # when "L2DerbyTrackZone" then L2DerbyTrackZone
        # when "L2DynamicZone" then L2DynamicZone
        # when "L2EffectZone" then L2EffectZone
        # when "L2FishingZone" then L2FishingZone
        # when "L2FortZone" then L2FortZone
        # when "L2HqZone" then L2HqZone
        # when "L2JailZone" then L2JailZone
        # when "L2LandingZone" then L2LandingZone
        # when "L2MotherTreeZone" then L2MotherTreeZone
        # when "L2NoLandingZone" then L2NoLandingZone
        # when "L2NoRestartZone" then L2NoRestartZone
        # when "L2NoStoreZone" then L2NoStoreZone
        # when "L2NoSummonFriendZone" then L2NoSummonFriendZone
        # when "L2OlympiadStadiumZone" then L2OlympiadStadiumZone
        # when "L2PeaceZone" then L2PeaceZone
        # when "L2ResidenceHallTeleportZone" then L2ResidenceHallTeleportZone
        # when "L2ResidenceTeleportZone" then L2ResidenceTeleportZone
        # when "L2ResidenceZone" then L2ResidenceZone
        # when "L2RespawnZone" then L2RespawnZone
        # when "L2ScriptZone" then L2ScriptZone
        # when "L2SiegableHallZone" then L2SiegableHallZone
        # when "L2SiegeZone" then L2SiegeZone
        # when "L2SwampZone" then L2SwampZone
        # when "L2TownZone" then L2TownZone
        # when "L2WaterZone" then L2WaterZone
        # end

        constructor_name = "L2#{zone_type}"
        # constructor = nil
        # {% for sub in L2ZoneType.all_subclasses %}
        #   if constructor_name == {{sub.stringify}}
        #     constructor = {{sub.id}}
        #   end
        # {% end %}
        constructor = nil
        {% begin %}
          case constructor_name
          {% for sub in L2ZoneType.all_subclasses %}
            when {{sub.stringify}}
              constructor = {{sub}}
          {% end %}
          else
            # automatically added
          end

        {% end %}

        if constructor
          temp = constructor.new(zone_id)
          temp.zone = zone_form
        else
          warn { "No zone type with name #{constructor_name}." }
          next
        end

        d.each_element do |cd|
          case cd.name.casecmp
          when "stat"
            temp.set_parameter(cd["name"], cd["val"])
          when "spawn"
            spawn_x = cd["X"].to_i
            spawn_y = cd["Y"].to_i
            spawn_z = cd["Z"].to_i
            val = cd["type"]?
            temp.as(L2ZoneRespawn).parse_loc(spawn_x, spawn_y, spawn_z, val)
          when "race"
            race = cd["name"]
            point = cd["point"]
            temp.as(L2RespawnZone).add_race_respawn_point(race, point)
          else
            # automatically added
          end

        end

        if check_id(zone_id)
          warn { "Zone with id #{zone_id} overrides previous definition." }
        end

        if zone_name && !zone_name.empty?
          temp.name = zone_name
        end

        add_zone(zone_id, temp)

        L2World.world_regions.each_with_index do |regions, x|
          regions.each_with_index do |reg, y|
            ax = (x - L2World::OFFSET_X) << L2World::SHIFT_BY
            bx = (x + 1 - L2World::OFFSET_X) << L2World::SHIFT_BY
            ay = (y - L2World::OFFSET_Y) << L2World::SHIFT_BY
            by = (y + 1 - L2World::OFFSET_Y) << L2World::SHIFT_BY

            if temp.zone.intersects_rectangle?(ax, bx, ay, by)
              reg.add_zone(temp)
            end
          end
        end
      end
    end
  end

  private def check_id(id : Int) : Bool
    CLASS_ZONES.local_each_value.any? &.has_key?(id)
  end

  def add_zone(id : Int32, zone : L2ZoneType)
    if map = CLASS_ZONES[zone.class]?
      map[id] = zone
    else
      CLASS_ZONES[zone.class] = {id => zone}
    end
  end

  def size : Int32
    CLASS_ZONES.local_each_value.sum &.size
  end

  def get_all_zones(zone_type : T.class) : Slice(T) forall T
    CLASS_ZONES[zone_type].values_slice.unsafe_as(Slice(T))
  end

  def get_all_zones(zone_type : T.class, & : T ->) forall T
    CLASS_ZONES[zone_type].each_value { |zone| yield zone.as(T) }
  end

  def get_zone_by_id(id : Int32) : L2ZoneType?
    CLASS_ZONES.each_value do |map|
      if val = map[id]?
        return val
      end
    end

    nil
  end

  def get_zone_by_id(id : Int32, zone_type : T.class) : T? forall T
    CLASS_ZONES[zone_type][id]?.as(T?)
  end

  def get_zone(obj : L2Object?, type : T.class) : T? forall T
    get_zone(*obj.xyz, type) if obj
  end

  def get_zone(x : Int32, y : Int32, z : Int32, type : T.class) : T? forall T
    L2World.get_region(x, y).zones.find do |zone|
      zone.inside_zone?(x, y, z) && zone.class <= type
    end.as(T?)
  end

  def get_zones(obj : L2Object, & : L2ZoneType ->) : Nil
    get_zones(*obj.xyz) { |zone| yield zone }
  end

  def get_zones(x : Int32, y : Int32, & : L2ZoneType ->) : Nil
    L2World.get_region(x, y).zones.each do |zone|
      if zone.inside_zone?(x, y)
        yield zone
      end
    end
  end

  def get_zones(x : Int32, y : Int32, z : Int32, & : L2ZoneType ->) : Nil
    L2World.get_region(x, y).zones.each do |zone|
      if zone.inside_zone?(x, y, z)
        yield zone
      end
    end
  end

  def get_spawn_territory(name : String) : NpcSpawnTerritory?
    SPAWN_TERRITORIES[name]?
  end

  def get_spawn_territories(object : L2Object)
    ret = [] of NpcSpawnTerritory
    SPAWN_TERRITORIES.each_value do |territory|
      if territory.inside_zone?(*object.xyz)
        ret << territory
      end
    end
    ret
  end

  def get_spawn_territories(object : L2Object, & : NpcSpawnTerritory ->) : Nil
    SPAWN_TERRITORIES.each_value do |territory|
      if territory.inside_zone?(*object.xyz)
        yield territory
      end
    end
  end

  def get_arena(char : L2Character?) : L2ArenaZone?
    return unless char

    get_zones(*char.xyz).each do |zone|
      if zone.is_a?(L2ArenaZone) && zone.character_in_zone?(char)
        return zone
      end
    end

    nil
  end

  def get_olympiad_stadium(char : L2Character?) : L2OlympiadStadiumZone?
    return unless char

    get_zones(*char.xyz).each do |zone|
      if zone.is_a?(L2OlympiadStadiumZone) && zone.character_in_zone?(char)
        return zone
      end
    end

    nil
  end

  def get_closest_zone(obj : L2Object, type : T.class) : T? forall T
    unless zone = get_zone(obj, type)
      closest = Float64::MAX
      CLASS_ZONES[type].each_value do |temp|
        dist = temp.get_distance_to_zone(obj)
        if dist < closest
          closest = dist
          zone = temp
        end
      end
    end

    zone
  end

  def clear_debug_items
    if tmp = @@debug_items
      tmp.each &.delete_me
      tmp.clear
    end
  end

  def get_settings(name : String?) : AbstractZoneSettings?
    SETTINGS[name]? if name
  end
end