require "../models/l2_map_region"

module MapRegionManager
  extend self
  extend XMLReader

  private REGIONS = {} of String => L2MapRegion
  private DEFAULT_RESPAWN = "talking_island_town"

  def load
    REGIONS.clear
    parse_datapack_directory("mapregion")
    info { "Loaded #{REGIONS.size} regions." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("region") do |d|
        name = d["name"]
        town = d["town"]
        loc_id = d["locId"].to_i
        castle = d["castle"].to_i
        bbs = d["bbs"].to_i
        region = L2MapRegion.new(name, town, loc_id, castle, bbs)
        d.each_element do |c|
          if c.name.casecmp?("respawnPoint")
            spawn_x = c["X"].to_i
            spawn_y = c["Y"].to_i
            spawn_z = c["Z"].to_i
            other = c["isOther"]?.try &.casecmp?("true")
            chaotic = c["isChaotic"]?.try &.casecmp?("true")
            banish = c["isBanish"]?.try &.casecmp?("true")

            if other
              region.add_other_spawn(spawn_x, spawn_y, spawn_z)
            elsif chaotic
              region.add_chaotic_spawn(spawn_x, spawn_y, spawn_z)
            elsif banish
              region.add_banish_spawn(spawn_x, spawn_y, spawn_z)
            else
              region.add_spawn(spawn_x, spawn_y, spawn_z)
            end
          elsif c.name.casecmp?("map")
            region.add_map(c["X"].to_i, c["Y"].to_i)
          elsif c.name.casecmp?("banned")
            region.add_banned_race(c["race"], c["point"])
          end
        end
        REGIONS[name] = region
      end
    end
  end

  def get_map_region(obj : L2Object) : L2MapRegion?
    get_map_region(obj.x, obj.y)
  end

  def get_map_region(x : Int32, y : Int32) : L2MapRegion?
    map_reg_x, map_reg_y = get_map_region_x(x), get_map_region_y(y)
    REGIONS.find_value &.zone_in_region?(map_reg_x, map_reg_y)
  end

  def get_map_region_loc_id(obj : L2Object) : Int32
    get_map_region_loc_id(obj.x, obj.y)
  end

  def get_map_region_loc_id(x : Int32, y : Int32) : Int32
    if reg = get_map_region(x, y)
      return reg.loc_id
    end

    0
  end

  def get_map_region_x(x)
    (x >> 15) + 9 + 11
  end

  def get_map_region_y(y)
    (y >> 15) + 10 + 8
  end

  def get_closest_town_name(char)
    get_map_region(char).try &.town || "Aden Castle Town"
  end

  def get_area_castle(char)
    get_map_region(char).try &.castle || 0
  end

  def get_restart_region(char, point)
    region = REGIONS[point]

    if tmp = region.banned_race[char.race]?
      get_restart_region(char, tmp)
    end

    region
  rescue
    REGIONS[DEFAULT_RESPAWN]
  end

  def get_map_region_by_name(name : String)
    REGIONS[name]
  end

  def get_tele_to_location(char : L2Character, where : TeleportWhereType) : Location
    if char.player?
      pc = char.acting_player

      castle = nil
      fort = nil
      clan_hall = nil
      clan = pc.clan?

      if clan && !pc.flying_mounted? && !pc.flying?
        if where.clanhall?
          if hall = ClanHallManager.get_abstract_hall_by_owner(clan)
            if zone = hall.zone?
              if pc.karma > 0
                return zone.chaotic_spawn_loc
              end

              return zone.spawn_loc
            end
          end
        end

        if where.castle?
          castle = CastleManager.get_castle_by_owner(clan)

          unless castle
            castle = CastleManager.get_castle(pc)
            unless castle && castle.siege.in_progress? && castle.siege.get_defender_clan(clan)
              castle = nil
            end
          end

          if castle && castle.residence_id > 0
            if pc.karma > 0
              return castle.residence_zone.chaotic_spawn_loc
            end

            return castle.residence_zone.spawn_loc
          end
        end

        if where.fortress?
          fort = FortManager.get_fort_by_owner(clan)

          unless fort
            fort = FortManager.get_fort(pc)
            unless fort && fort.siege.in_progress? && fort.owner_clan == clan
              fort = nil
            end

            if fort && fort.residence_id > 0
              if pc.karma > 0
                return fort.residence_zone.chaotic_spawn_loc
              end

              return fort.residence_zone.spawn_loc
            end
          end
        end

        if where.siegeflag?
          castle = CastleManager.get_castle(pc)
          fort = FortManager.get_fort(pc)
          clan_hall = ClanHallManager.get_nearby_abstract_hall(pc.x, pc.y, 10000)
          if tw_flag = TerritoryWarManager.get_hq_for_clan(clan)
            return tw_flag.location
          elsif castle
            if castle.siege.in_progress?
              if flags = castle.siege.get_flag(clan)
                unless flags.empty?
                  return flags.first.location
                end
              end
            end
          elsif fort
            if fort.siege.in_progress?
              if flags = fort.siege.get_flag(clan)
                unless flags.empty?
                  return flags.first.location
                end
              end
            end
          elsif clan_hall && clan_hall.siegable_hall?
            s_hall = clan_hall.as(SiegableHall)
            if flags = s_hall.siege.get_flag(clan)
              unless flags.empty?
                return flags.first.location
              end
            end
          end
        end
      end

      if pc.karma > 0
        if zone = ZoneManager.get_zone(pc, L2RespawnZone)
          temp = get_restart_region(pc, zone.get_respawn_point(pc))
        else
          temp = get_map_region(pc)
        end

        if temp
          return temp.chaotic_spawn_loc
        else
          return REGIONS[DEFAULT_RESPAWN].chaotic_spawn_loc
        end
      end

      if castle = CastleManager.get_castle(pc)
        if castle.siege.in_progress?
          if clan = pc.clan?
            if castle.siege.defender?(clan) || castle.siege.attacker?(clan)
              if SevenSigns.get_seal_owner(SevenSigns::SEAL_STRIFE) == SevenSigns::CABAL_DAWN
                return castle.residence_zone.other_spawn_loc
              end
            end
          end
        end
      end

      if pc.instance_id > 0
        if inst = InstanceManager.get_instance(pc.instance_id)
          if loc = inst.exit_loc
            return loc
          end
        end
      end
    end

    zone = ZoneManager.get_zone(char, L2RespawnZone)
    temp = nil

    if zone
      temp = get_restart_region(char, zone.get_respawn_point(char.acting_player))
    else
      temp = get_map_region(char)
    end

    if temp
      temp.spawn_loc
    else
      REGIONS[DEFAULT_RESPAWN].spawn_loc
    end
  end
end
