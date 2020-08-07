class Packets::Outgoing::GMViewCharacterInfo < GameServerPacket
  @move_multiplier : Float64

  def initialize(pc : L2PcInstance)
    @pc = pc
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
    c 0x95

    l @pc
    d @pc.heading
    d @pc.l2id
    s @pc.name
    d @pc.race.to_i
    d @pc.appearance.sex ? 1 : 0
    d @pc.class_id.to_i
    d @pc.level
    q @pc.exp
    f (@pc.exp.to_f - ExperienceData.get_exp_for_level(@pc.level)) / (ExperienceData.get_exp_for_level(@pc.level &+ 1) - ExperienceData.get_exp_for_level(@pc.level))
    d @pc.str
    d @pc.dex
    d @pc.con
    d @pc.int
    d @pc.wit
    d @pc.men
    d @pc.max_hp
    d @pc.current_hp.to_i
    d @pc.max_mp
    d @pc.current_mp.to_i
    d @pc.sp
    d @pc.current_load
    d @pc.max_load
    d @pc.pk_kills
    paperdoll_order do |slot|
      d @pc.inventory.get_paperdoll_l2id(slot)
    end

    paperdoll_order do |slot|
      d @pc.inventory.get_paperdoll_item_display_id(slot)
    end

    paperdoll_order do |slot|
      d @pc.inventory.get_paperdoll_augmentation_id(slot)
    end
    d @pc.inventory.talisman_slots
    d @pc.inventory.can_equip_cloak? ? 1 : 0
    d @pc.get_p_atk(nil).to_i
    d @pc.p_atk_spd.to_i
    d @pc.get_p_def(nil).to_i
    d @pc.get_evasion_rate(nil)
    d @pc.accuracy
    d @pc.get_critical_hit(nil, nil)
    d @pc.get_m_atk(nil, nil).to_i

    d @pc.m_atk_spd
    d @pc.p_atk_spd.to_i

    d @pc.get_m_def(nil, nil).to_i

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

    s @pc.title
    d @pc.clan_id
    d @pc.clan_crest_id
    d @pc.ally_id
    c @pc.mount_type.to_i
    c @pc.private_store_type.id
    c @pc.has_dwarven_craft? ? 1 : 0
    d @pc.pk_kills
    d @pc.pvp_kills

    h @pc.recom_left
    h @pc.recom_have
    d @pc.class_id.to_i
    d 0x00 # unknown. special effects?
    d @pc.max_cp
    d @pc.current_cp.to_i

    c @pc.running? ? 1 : 0

    c 321

    d @pc.pledge_class

    c @pc.noble? ? 1 : 0
    c @pc.hero? ? 1 : 0

    d @pc.appearance.name_color
    d @pc.appearance.title_color

    attack_attribute = @pc.attack_element
    h attack_attribute
    h @pc.get_attack_element_value(attack_attribute)
    6.times { |i| h @pc.get_defense_element_value(i) }
    d @pc.fame
    d @pc.vitality_points
  end
end
