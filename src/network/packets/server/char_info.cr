class Packets::Outgoing::CharInfo < GameServerPacket
  @l2id : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @vehicle_id : Int32
  @heading : Int32
  @m_atk_spd : Int32
  @p_atk_spd : Int32
  @attack_speed_multiplier : Float32
  @move_multiplier : Float64
  @run_spd = 0
  @walk_spd = 0
  @swim_run_spd = 0
  @swim_walk_spd = 0
  @fly_run_spd : Int32
  @fly_walk_spd : Int32

  def initialize(pc : L2PcInstance)
    @pc = pc
    @l2id = pc.l2id
    if (vehicle = pc.vehicle) && (pos = pc.in_vehicle_position)
      @x, @y, @z = pos.xyz
      @vehicle_id = vehicle.l2id
    else
      @x, @y, @z = pc.xyz
      @vehicle_id = 0
    end

    @heading = pc.heading
    @m_atk_spd = pc.m_atk_spd
    @p_atk_spd = pc.p_atk_spd.to_i
    @attack_speed_multiplier = pc.attack_speed_multiplier

    @move_multiplier = pc.movement_speed_multiplier
    if @move_multiplier != 0
      @run_spd       = (@pc.run_speed       / @move_multiplier).round.to_i
      @walk_spd      = (@pc.walk_speed      / @move_multiplier).round.to_i
      @swim_run_spd  = (@pc.swim_run_speed  / @move_multiplier).round.to_i
      @swim_walk_spd = (@pc.swim_walk_speed / @move_multiplier).round.to_i
    end

    @fly_run_spd = pc.flying? ? @run_spd : 0
    @fly_walk_spd = pc.flying? ? @walk_spd : 0
    self.invisible = pc.invisible?
  end

  protected setter l2id, x, y, z, heading

  def self.new(decoy : L2Decoy)
    ci = new(decoy.acting_player)

    ci.l2id = decoy.l2id
    ci.x, ci.y, ci.z = decoy.xyz
    ci.heading = decoy.heading
    ci
  end

  private def write_impl
    gm_see_invis = false

    if invisible?
      pc = client.active_char
      if pc && pc.override_see_all_players?
        gm_see_invis = true
      end
    end

    if @pc.poly? && @pc.poly.morphed?
      template = NpcData[@pc.poly.poly_id]?
    end

    if template
      c 0x0c

      d @l2id
      d template.id + 1_000_000
      d @pc.karma > 0 ? 1 : 0
      d @x
      d @y
      d @z
      d @heading
      d 0
      d @m_atk_spd
      d @p_atk_spd
      d @run_spd
      d @walk_spd
      d @swim_run_spd
      d @swim_walk_spd
      d @fly_run_spd
      d @fly_walk_spd
      d @fly_run_spd
      d @fly_walk_spd
      f @move_multiplier
      f @attack_speed_multiplier
      f template.f_collision_radius
      f template.f_collision_height
      d template.r_hand_id
      d template.chest_id
      d template.l_hand_id
      c 1
      c @pc.running? ? 1 : 0
      c @pc.in_combat? ? 1 : 0
      c @pc.looks_dead? ? 1 : 0
      c !gm_see_invis && invisible? ? 1 : 0

      d -1
      s @pc.appearance.visible_name
      d -1
      s gm_see_invis ? "Invisible" : @pc.appearance.visible_title

      if gm_see_invis
        d @pc.abnormal_visual_effects | AbnormalVisualEffect::STEALTH.mask
      else
        d @pc.abnormal_visual_effects
      end

      d @pc.clan_id
      d @pc.clan_crest_id
      d @pc.ally_id
      d @pc.ally_crest_id

      c @pc.flying? ? 2 : 0
      c @pc.team.to_i

      f template.f_collision_radius
      f template.f_collision_height

      d 0
      d @pc.flying? ? 2 : 0

      d 0

      d 0
      c template.targetable? ? 1 : 0
      c template.show_name? ? 1 : 0
      c @pc.abnormal_visual_effects_special
      d 0
    else
      c 0x31

      d @x
      d @y
      d @z
      d @vehicle_id
      d @l2id
      s @pc.appearance.visible_name
      d @pc.race.to_i
      d @pc.appearance.sex ? 1 : 0
      d @pc.base_class
      paperdoll_order do |slot|
        d @pc.inventory.get_paperdoll_item_display_id(slot)
      end
      paperdoll_order do |slot|
        d @pc.inventory.get_paperdoll_augmentation_id(slot)
      end
      d @pc.inventory.talisman_slots
      d @pc.inventory.can_equip_cloak? ? 1 : 0
      d @pc.pvp_flag
      d @pc.karma
      d @m_atk_spd
      d @p_atk_spd
      d 0x00
      d @run_spd
      d @walk_spd
      d @swim_run_spd
      d @swim_walk_spd
      d @fly_run_spd
      d @fly_walk_spd
      d @fly_run_spd
      d @fly_walk_spd

      f @move_multiplier
      f @pc.attack_speed_multiplier
      f @pc.collision_radius
      f @pc.collision_height

      d @pc.appearance.hair_style
      d @pc.appearance.hair_color
      d @pc.appearance.face

      s gm_see_invis ? "Invisible" : @pc.appearance.visible_title

      if @pc.cursed_weapon_equipped?
        q 0
        q 0
      else
        d @pc.clan_id
        d @pc.clan_crest_id
        d @pc.ally_id
        d @pc.ally_crest_id
      end

      c @pc.sitting? ? 0 : 1
      c @pc.running? ? 1 : 0
      c @pc.in_combat? ? 1 : 0
      c !@pc.in_olympiad_mode? && @pc.looks_dead? ? 1 : 0
      c !gm_see_invis && invisible? ? 1 : 0
      c @pc.mount_type.to_i # 1: Strider, 2: Wyvern, 3: Great Wolf, 0: none
      c @pc.private_store_type.to_i

      h @pc.cubics.size
      @pc.cubics.each_key { |id| h id }

      c @pc.in_party_match_room? ? 1 : 0

      if gm_see_invis
        d @pc.abnormal_visual_effects | AbnormalVisualEffect::STEALTH.mask
      else
        d @pc.abnormal_visual_effects
      end

      c @pc.inside_water_zone? ? 1 : @pc.flying_mounted? ? 2 : 0

      h @pc.recom_have

      d @pc.mount_npc_id + 1_000_000
      d @pc.class_id.to_i
      d 0x00 # unk
      c @pc.mounted? ? 0 : @pc.enchant_effect

      c @pc.team.to_i

      d @pc.clan_crest_large_id
      c @pc.noble? ? 1 : 0 # Symbol on char menu ctrl+I
      c @pc.hero? || (@pc.gm? && Config.gm_hero_aura) ? 1 : 0

      c @pc.fishing? ? 1 : 0 # 0x01: Fishing Mode (Cant be undone by setting back to 0)

      d @pc.fish_x
      d @pc.fish_y
      d @pc.fish_z
      d @pc.appearance.name_color
      d @heading
      d @pc.pledge_class
      d @pc.pledge_type
      d @pc.appearance.title_color
      if @pc.cursed_weapon_equipped?
        d CursedWeaponsManager.get_level(@pc.cursed_weapon_equipped_id)
      else
        d 0
      end
      d @pc.clan_id > 0 ? @pc.clan.not_nil!.reputation_score : 0
      d @pc.transformation_display_id
      d @pc.agathion_id
      d 0x01
      d @pc.abnormal_visual_effects_special
    end
  end

  private def paperdoll_order
    yield Inventory::UNDER
    yield Inventory::HEAD
    yield Inventory::RHAND
    yield Inventory::LHAND
    yield Inventory::GLOVES
    yield Inventory::CHEST
    yield Inventory::LEGS
    yield Inventory::FEET
    yield Inventory::CLOAK
    yield Inventory::RHAND
    yield Inventory::HAIR
    yield Inventory::HAIR2
    yield Inventory::RBRACELET
    yield Inventory::LBRACELET
    yield Inventory::DECO1
    yield Inventory::DECO2
    yield Inventory::DECO3
    yield Inventory::DECO4
    yield Inventory::DECO5
    yield Inventory::DECO6
    yield Inventory::BELT
  end
end
