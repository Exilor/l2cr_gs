class Packets::Outgoing::UserInfo < GameServerPacket
  @move_multiplier : Float64

  def initialize(pc : L2PcInstance)
    @pc = pc
    @territory_id = TerritoryWarManager.get_registered_territory_id(@pc)
    @relation = @pc.clan_leader? ? 0x40 : 0
    if @pc.siege_state == 1
      if @territory_id == 0
        @relation |= 0x180
      else
        @relation |= 0x1000
      end
    end

    if @pc.siege_state == 2
      @relation |= 0x80
    end

    if (airship = @pc.airship) && airship.captain?(@pc)
      @airship_helm = airship.helm_item_id
    else
      @airship_helm = 0
    end

    @move_multiplier = @pc.movement_speed_multiplier
    if @move_multiplier == 0
      @run_speed       = 0
      @walk_speed      = 0
      @swim_run_speed  = 0
      @swim_walk_speed = 0
    else
      @run_speed       = (@pc.run_speed       / @move_multiplier).round.to_i
      @walk_speed      = (@pc.walk_speed      / @move_multiplier).round.to_i
      @swim_run_speed  = (@pc.swim_run_speed  / @move_multiplier).round.to_i
      @swim_walk_speed = (@pc.swim_walk_speed / @move_multiplier).round.to_i
    end
    @fly_run_speed   = @pc.flying? ? @run_speed : 0
    @fly_walk_speed  = @pc.flying? ? @walk_speed : 0
  end

  private def write_impl
    c 0x32

    l @pc
    d @pc.vehicle.try &.l2id || 0
    d @pc.l2id
    s @pc.appearance.visible_name
    d @pc.race.to_i
    d @pc.appearance.sex ? 1 : 0
    d @pc.base_class
    d @pc.level
    q @pc.exp

    f (@pc.exp.to_f - ExperienceData.get_exp_for_level(@pc.level)) / (ExperienceData.get_exp_for_level(@pc.level + 1) - ExperienceData.get_exp_for_level(@pc.level))

    d @pc.str
    d @pc.dex
    d @pc.con
    d @pc.int
    d @pc.wit
    d @pc.men
    d @pc.max_hp
    d @pc.current_hp
    d @pc.max_mp
    d @pc.current_mp
    d @pc.sp
    d @pc.current_load
    d @pc.max_load

    d @pc.active_weapon_item ? 40 : 20

    inv = @pc.inventory

    paperdoll_order do |slot|
      d inv.get_paperdoll_l2id(slot)
    end

    paperdoll_order do |slot|
      d inv.get_paperdoll_item_display_id(slot)
    end

    paperdoll_order do |slot|
      d inv.get_paperdoll_augmentation_id(slot)
    end


    d inv.talisman_slots
    d inv.can_equip_cloak? ? 1 : 0
    d @pc.get_p_atk(nil)
    d @pc.p_atk_spd
    d @pc.get_p_def(nil)
    d @pc.get_evasion_rate(nil)
    d @pc.accuracy
    d @pc.get_critical_hit(nil, nil)
    d @pc.get_m_atk(nil, nil)
    d @pc.m_atk_spd
    d @pc.p_atk_spd
    d @pc.get_m_def(nil, nil)
    d @pc.pvp_flag
    d @pc.karma
    d @run_speed
    d @walk_speed
    d @swim_run_speed
    d @swim_walk_speed
    d @fly_run_speed
    d @fly_walk_speed

    d @fly_run_speed
    d @fly_walk_speed

    f @move_multiplier
    f @pc.attack_speed_multiplier
    f @pc.collision_radius
    f @pc.collision_height

    d @pc.appearance.hair_style
    d @pc.appearance.hair_color
    d @pc.appearance.face
    d @pc.gm? ? 1 : 0

    title = @pc.gm? && @pc.invisible? ? "Invisible" : @pc.title

    if @pc.poly? && @pc.poly.morphed?
      poly_obj = NpcData[@pc.poly.poly_id]?
      if poly_obj
        title = "#{title} - #{poly_obj.name}"
      end
    end

    s title

    d @pc.clan_id
    d @pc.clan_crest_id
    d @pc.ally_id
    d @pc.ally_crest_id
    d @relation

    c @pc.mount_type.to_i
    c @pc.private_store_type.id
    c @pc.has_dwarven_craft? ? 1 : 0

    d @pc.pk_kills
    d @pc.pvp_kills

    h @pc.cubics.size
    @pc.cubics.each_key { |id| h id }

    c @pc.in_party_match_room? ? 1 : 0

    d @pc.invisible? ? @pc.abnormal_visual_effects | AbnormalVisualEffect::STEALTH.mask : @pc.abnormal_visual_effects
    c @pc.inside_water_zone? ? 1 : @pc.flying_mounted? ? 2 : 0

    d @pc.clan_privileges.bitmask

    h @pc.recom_left
    h @pc.recom_have
    d @pc.mount_npc_id > 0 ? @pc.mount_npc_id + 1_000_000 : 0
    h @pc.inventory_limit

    d @pc.class_id.to_i
    d 0x00
    d @pc.max_cp
    d @pc.current_cp

    c @pc.mounted? || @airship_helm != 0 ? 0 : @pc.enchant_effect
    c @pc.team.to_i

    d @pc.clan_crest_large_id

    c @pc.noble? ? 1 : 0
    c @pc.hero? || (@pc.gm? && Config.gm_hero_aura) ? 1 : 0
    c @pc.fishing? ? 1 : 0

    d @pc.fish_x
    d @pc.fish_y
    d @pc.fish_z
    d @pc.appearance.name_color

    c @pc.running? ? 1 : 0

    d @pc.pledge_class
    d @pc.pledge_type
    d @pc.appearance.title_color
    d @pc.cursed_weapon_equipped? ? CursedWeaponsManager.get_level(@pc.cursed_weapon_equipped_id) : 0

    d @pc.transformation_display_id

    attack_attribute = @pc.attack_element
    h attack_attribute
    h @pc.get_attack_element_value(attack_attribute)
    h @pc.get_defense_element_value(Elementals::FIRE)
    h @pc.get_defense_element_value(Elementals::WATER)
    h @pc.get_defense_element_value(Elementals::WIND)
    h @pc.get_defense_element_value(Elementals::EARTH)
    h @pc.get_defense_element_value(Elementals::HOLY)
    h @pc.get_defense_element_value(Elementals::DARK)

    d @pc.agathion_id
    d @pc.fame
    d @pc.minimap_allowed? ? 1 : 0
    d @pc.vitality_points
    d @pc.abnormal_visual_effects_special

    # # unused by L2J
    # d @territory_id
    # d @disguised ? 1 : 0
    # d @territory_id
  end
end
