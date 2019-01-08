class EffectHandler::Pumping < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super

    unless params.get_string("power", nil)
      raise "effect with no power"
    end

    @power = params.get_f64("power", 0)
  end

  def instant?
    true
  end

  def effect_type
    L2EffectType::FISHING
  end

  def on_start(info)
    return unless pc = info.effector.as?(L2PcInstance)

    unless fish = pc.fish_combat
      pc.send_packet(SystemMessageId::CAN_USE_PUMPING_ONLY_WHILE_FISHING)
      pc.action_failed
      return
    end

    return unless wep_item = pc.active_weapon_item?
    return unless wep_inst = pc.active_weapon_instance?

    pen = 0

    if pc.charged_shot?(ShotType::FISH_SOULSHOTS)
      ss = 2
    else
      ss = 1
    end

    fishing_rod = FishingRodsData.get_fishing_rod(wep_item.id)
    grade_bonus = fishing_rod.level * 0.1
    dmg = fishing_rod.damage
    dmg += pc.calc_stat(Stats::FISHING_EXPERTISE) + @power
    dmg *= grade_bonus * ss
    dmg = dmg.to_i

    if pc.get_skill_level(1315) <= info.skill.level - 2 # fish expertise
      pc.send_packet(SystemMessageId::REELING_PUMPING_3_LEVELS_HIGHER_THAN_FISHING_PENALTY)
      pen = (dmg * 0.05).to_i
      dmg = (dmg - pen).to_i
    end

    if ss > 1
      wep_inst.set_charged_shot(ShotType::FISH_SOULSHOTS, false)
    end

    fish.use_pumping(dmg, pen)
  end
end
