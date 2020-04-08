class EffectHandler::Fishing < AbstractEffect
  MIN_BAIT_DISTANCE = 90
  MAX_BAIT_DISTANCE = 250

  def instant? : Bool
    true
  end

  def effect_type : EffectType
    EffectType::FISHING_START
  end

  def on_start(info)
    pc = info.effector
    return unless pc.is_a?(L2PcInstance)

    if !Config.allowfishing && !pc.override_skill_conditions?
      pc.send_message("Fishing is disabled.")
      return
    end

    if pc.fishing?
      if combat = pc.fish_combat
        combat.do_die(false)
      else
        pc.end_fishing(false)
      end

      pc.send_packet(SystemMessageId::FISHING_ATTEMPT_CANCELLED)
      return
    end

    wep = pc.active_weapon_item
    if wep.nil? || wep.item_type != WeaponType::FISHINGROD
      pc.send_packet(SystemMessageId::FISHING_POLE_NOT_EQUIPPED)
      return
    end

    wep2 = pc.inventory.lhand_slot
    if wep2.nil? || wep2.item_type != EtcItemType::LURE
      pc.send_packet(SystemMessageId::BAIT_ON_HOOK_BEFORE_FISHING)
      return
    end

    unless pc.gm?
      if pc.in_boat?
        pc.send_packet(SystemMessageId::CANNOT_FISH_ON_BOAT)
        return
      end

      if pc.in_craft_mode? || pc.in_store_mode?
        pc.send_packet(SystemMessageId::CANNOT_FISH_WHILE_USING_RECIPE_BOOK)
        return
      end

      if pc.inside_water_zone?
        pc.send_packet(SystemMessageId::CANNOT_FISH_UNDER_WATER)
        return
      end
    end

    distance = Rnd.rand(MIN_BAIT_DISTANCE..MAX_BAIT_DISTANCE)
    angle = Util.convert_heading_to_degree(pc.heading)
    radian = Math.to_radians(angle)
    sin = Math.sin(radian)
    cos = Math.cos(radian)
    bait_x = (pc.x + (cos * distance)).to_i
    bait_y = (pc.y + (sin * distance)).to_i

    fishing_zone = nil
    water_zone = nil

    ZoneManager.get_zones(bait_x, bait_y) do |zone|
      if zone.is_a?(L2FishingZone)
        fishing_zone = zone
      elsif zone.is_a?(L2WaterZone)
        water_zone = zone
      end

      break if fishing_zone && water_zone
    end

    bait_z = compute_bait_z(pc, bait_x, bait_y, fishing_zone, water_zone)
    if bait_z == Int32::MIN
      MAX_BAIT_DISTANCE.downto(MIN_BAIT_DISTANCE) do |dist|
        bait_x = pc.x + (cos * dist).to_i
        bait_y = pc.y + (sin * dist).to_i

        fishing_zone = nil
        water_zone = nil

        ZoneManager.get_zones(bait_x, bait_y) do |zone|
          if zone.is_a?(L2FishingZone)
            fishing_zone = zone
          elsif zone.is_a?(L2WaterZone)
            water_zone = zone
          end

          break if fishing_zone && water_zone
        end

        bait_z = compute_bait_z(pc, bait_x, bait_y, fishing_zone, water_zone)
        if bait_z != Int32::MIN
          break
        end
      end

      if bait_z == Int32::MIN
        if pc.gm?
          debug "Non-gms wouldn't be able to fish here."
          bait_z = pc.z
        else
          pc.send_packet(SystemMessageId::CANNOT_FISH_HERE)
          return
        end
      end
    end

    unless pc.destroy_item("Fishing", wep2, 1, nil, false)
      pc.send_packet(SystemMessageId::NOT_ENOUGH_BAIT)
      return
    end

    pc.lure = wep2
    pc.start_fishing(bait_x, bait_y, bait_z)
  end

  private def compute_bait_z(pc, bait_x, bait_y, fishing_zone, water_zone) : Int32
    unless fishing_zone
      return Int32::MIN
    end

    unless water_zone
      return Int32::MIN
    end

    bait_z = water_zone.water_z

    unless GeoData.can_see_target?(*pc.xyz, bait_x, bait_y, bait_z)
      return Int32::MIN
    end

    if GeoData.has_geo?(bait_x, bait_y)
      if GeoData.get_height(bait_x, bait_y, bait_z) > bait_z
        return Int32::MIN
      end

      if GeoData.get_height(bait_x, bait_y, pc.z) > bait_z
        return Int32::MIN
      end
    end

    bait_z
  end
end
