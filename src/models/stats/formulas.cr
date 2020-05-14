require "../actor/instance/l2_siege_flag_instance"
require "../actor/instance/l2_static_object_instance"
require "../../enums/shot_type"

module Formulas
  extend self
  extend Loggable
  include Packets::Outgoing

  SHIELD_DEFENSE_FAILED = 0
  SHIELD_DEFENSE_SUCCEED = 1
  SHIELD_DEFENSE_PERFECT_BLOCK = 2

  {% for const in Stats.constants %}
    private {{const}} = Stats::{{const}}
  {% end %}

  private HP_REGENERATE_PERIOD = 3000 # ms.
  private MELEE_ATTACK_RANGE = 40

  @@npc_std_calculators : Slice(Calculator?)?
  @@std_door_calculators : Slice(Calculator?)?

  def npc_std_calculators : Slice(Calculator?)
    @@npc_std_calculators ||= begin
      std = Slice.new(Stats.size, nil.as(Calculator?))

      std[MAX_HP.to_i] = Calculator.new(FuncMaxHpMul::INSTANCE)
      std[MAX_MP.to_i] = Calculator.new(FuncMaxMpMul::INSTANCE)
      std[POWER_ATTACK.to_i] = Calculator.new(FuncPAtkMod::INSTANCE)
      std[MAGIC_ATTACK.to_i] = Calculator.new(FuncMAtkMod::INSTANCE)
      std[POWER_DEFENCE.to_i] = Calculator.new(FuncPDefMod::INSTANCE)
      std[MAGIC_DEFENCE.to_i] = Calculator.new(FuncMDefMod::INSTANCE)
      std[CRITICAL_RATE.to_i] = Calculator.new(FuncAtkCritical::INSTANCE)
      std[MCRITICAL_RATE.to_i] = Calculator.new(FuncMAtkCritical::INSTANCE)
      std[ACCURACY_COMBAT.to_i] = Calculator.new(FuncAtkAccuracy::INSTANCE)
      std[EVASION_RATE.to_i] = Calculator.new(FuncAtkEvasion::INSTANCE)
      std[POWER_ATTACK_SPEED.to_i] = Calculator.new(FuncPAtkSpeed::INSTANCE)
      std[MAGIC_ATTACK_SPEED.to_i] = Calculator.new(FuncMAtkSpeed::INSTANCE)
      std[MOVE_SPEED.to_i] = Calculator.new(FuncMoveSpeed::INSTANCE)

      std
    end
  end

  def std_door_calculators : Slice(Calculator?)
    @@std_door_calculators ||= begin
      std = Slice.new(Stats.size, nil.as(Calculator?))

      std[ACCURACY_COMBAT.to_i] = Calculator.new(FuncAtkAccuracy::INSTANCE)
      std[EVASION_RATE.to_i] = Calculator.new(FuncAtkEvasion::INSTANCE)
      std[POWER_DEFENCE.to_i] = Calculator.new(FuncGatesPDefMod::INSTANCE)
      std[MAGIC_DEFENCE.to_i] = Calculator.new(FuncGatesMDefMod::INSTANCE)

      std
    end
  end

  def get_regenerate_period(char : L2Character) : Int32
    char.door? ? HP_REGENERATE_PERIOD * 100 : HP_REGENERATE_PERIOD
  end

  def add_funcs_to_new_player(pc : L2PcInstance)
    pc.add_stat_func(FuncMaxHpMul::INSTANCE)
    pc.add_stat_func(FuncMaxCpMul::INSTANCE)
    pc.add_stat_func(FuncMaxMpMul::INSTANCE)
    pc.add_stat_func(FuncPAtkMod::INSTANCE)
    pc.add_stat_func(FuncMAtkMod::INSTANCE)
    pc.add_stat_func(FuncPDefMod::INSTANCE)
    pc.add_stat_func(FuncMDefMod::INSTANCE)
    pc.add_stat_func(FuncAtkCritical::INSTANCE)
    pc.add_stat_func(FuncMAtkCritical::INSTANCE)
    pc.add_stat_func(FuncAtkAccuracy::INSTANCE)
    pc.add_stat_func(FuncAtkEvasion::INSTANCE)
    pc.add_stat_func(FuncPAtkSpeed::INSTANCE)
    pc.add_stat_func(FuncMAtkSpeed::INSTANCE)
    pc.add_stat_func(FuncMoveSpeed::INSTANCE)

    pc.add_stat_func(FuncHenna::STR)
    pc.add_stat_func(FuncHenna::DEX)
    pc.add_stat_func(FuncHenna::INT)
    pc.add_stat_func(FuncHenna::MEN)
    pc.add_stat_func(FuncHenna::CON)
    pc.add_stat_func(FuncHenna::WIT)

    pc.add_stat_func(FuncArmorSet::STR)
    pc.add_stat_func(FuncArmorSet::DEX)
    pc.add_stat_func(FuncArmorSet::INT)
    pc.add_stat_func(FuncArmorSet::MEN)
    pc.add_stat_func(FuncArmorSet::CON)
    pc.add_stat_func(FuncArmorSet::WIT)
  end

  def add_funcs_to_new_summon(sum : L2Summon)
    sum.add_stat_func(FuncMaxHpMul::INSTANCE)
    sum.add_stat_func(FuncMaxMpMul::INSTANCE)
    sum.add_stat_func(FuncPAtkMod::INSTANCE)
    sum.add_stat_func(FuncMAtkMod::INSTANCE)
    sum.add_stat_func(FuncPDefMod::INSTANCE)
    sum.add_stat_func(FuncMDefMod::INSTANCE)
    sum.add_stat_func(FuncAtkCritical::INSTANCE)
    sum.add_stat_func(FuncMAtkCritical::INSTANCE)
    sum.add_stat_func(FuncAtkAccuracy::INSTANCE)
    sum.add_stat_func(FuncAtkEvasion::INSTANCE)
    sum.add_stat_func(FuncMoveSpeed::INSTANCE)
    sum.add_stat_func(FuncPAtkSpeed::INSTANCE)
    sum.add_stat_func(FuncMAtkSpeed::INSTANCE)
  end

  def hp_regen(char : L2Character) : Float64
    if char.is_a?(L2PcInstance)
      init = char.template.get_base_hp_regen(char.level)
    else
      init = char.template.base_hp_reg
    end

    if char.raid?
      hp_regen_multiplier = Config.raid_hp_regen_multiplier
    else
      hp_regen_multiplier = Config.hp_regen_multiplier
    end

    hp_regen_bonus = 0.0

    if Config.champion_enable && char.champion?
      hp_regen_multiplier *= Config.champion_hp_regen
    end

    if pc = char.as?(L2PcInstance)
      if SevenSignsFestival.instance.festival_in_progress? && pc.festival_participant?
        hp_regen_multiplier *= festival_regen_modifier(pc)
      else
        siege_modifier = siege_regen_modifier(pc)
        if siege_modifier > 0
          hp_regen_multiplier *= siege_modifier
        end
      end

      if pc.inside_clan_hall_zone? && (clan = pc.clan) && clan.hideout_id > 0
        zone = ZoneManager.get_zone(pc, L2ClanHallZone)
        pos_ch_idx = zone.try &.residence_id || -1
        clan_hall_index = clan.hideout_id
        if clan_hall_index > 0 && clan_hall_index == pos_ch_idx
          if hall = ClanHallManager.get_clan_hall_by_id(clan_hall_index)
            if func = hall.get_function(ClanHall::FUNC_RESTORE_HP)
              hp_regen_multiplier *= 1 + func.lvl.fdiv(100)
            end
          end
        end
      end

      if pc.inside_castle_zone? && (clan = pc.clan) && clan.castle_id > 0
        zone = ZoneManager.get_zone(pc, L2CastleZone)
        pos_castle_idx = zone.try &.residence_id || -1
        castle_index = clan.castle_id
        if castle_index > 0 && castle_index == pos_castle_idx
          if castle = CastleManager.get_castle_by_id(castle_index)
            if func = castle.get_function(Castle::FUNC_RESTORE_HP)
              hp_regen_multiplier *= 1 + func.lvl.fdiv(100)
            end
          end
        end
      end

      if pc.inside_fort_zone? && (clan = pc.clan) && clan.fort_id > 0
        zone = ZoneManager.get_zone(pc, L2FortZone)
        pos_fort_idx = zone.try &.residence_id || -1
        fort_index = clan.fort_id
        if fort_index > 0 && fort_index == pos_fort_idx
          if fort = FortManager.get_fort_by_id(fort_index)
            if func = fort.get_function(Castle::FUNC_RESTORE_HP)
              hp_regen_multiplier *= 1 + func.lvl.fdiv(100)
            end
          end
        end
      end

      if pc.inside_mother_tree_zone?
        if zone = ZoneManager.get_zone(pc, L2MotherTreeZone)
          hp_regen_bonus += zone.hp_regen_bonus
        end
      end

      if pc.sitting?
        hp_regen_multiplier *= 1.5
      elsif !pc.moving?
        hp_regen_multiplier *= 1.1
      elsif pc.running?
        hp_regen_multiplier *= 0.7
      end

      init *= char.level_mod * BaseStats::CON.calc_bonus(char)
    elsif char.is_a?(L2PetInstance)
      init = char.pet_level_data.pet_regen_hp * Config.pet_hp_regen_multiplier
    end

    (char.calc_stat(REGENERATE_HP_RATE, Math.max(init, 1)) + hp_regen_multiplier) + hp_regen_bonus
  end

  def mp_regen(char : L2Character) : Float64
    if char.is_a?(L2PcInstance)
      init = char.template.get_base_mp_regen(char.level)
    else
      init = char.template.base_mp_reg
    end
    mp_regen_multiplier = char.raid? ? Config.raid_mp_regen_multiplier : Config.mp_regen_multiplier
    mp_regen_bonus = 0.0

    if pc = char.as?(L2PcInstance)
      if SevenSignsFestival.instance.festival_in_progress? && pc.festival_participant?
        mp_regen_multiplier *= festival_regen_modifier(pc)
      else
        siege_modifier = siege_regen_modifier(pc)
        if siege_modifier > 0
          mp_regen_multiplier *= siege_modifier
        end
      end

      if pc.inside_clan_hall_zone? && (clan = pc.clan) && clan.hideout_id > 0
        zone = ZoneManager.get_zone(pc, L2ClanHallZone)
        pos_ch_idx = zone.try &.residence_id || -1
        clan_hall_index = clan.hideout_id
        if clan_hall_index > 0 && clan_hall_index == pos_ch_idx
          if hall = ClanHallManager.get_clan_hall_by_id(clan_hall_index)
            if func = hall.get_function(ClanHall::FUNC_RESTORE_MP)
              mp_regen_multiplier *= 1 + func.lvl.fdiv(100)
            end
          end
        end
      end

      if pc.inside_castle_zone? && (clan = pc.clan) && clan.castle_id > 0
        zone = ZoneManager.get_zone(pc, L2CastleZone)
        pos_castle_idx = zone.try &.residence_id || -1
        castle_index = clan.castle_id
        if castle_index > 0 && castle_index == pos_castle_idx
          if castle = CastleManager.get_castle_by_id(castle_index)
            if func = castle.get_function(Castle::FUNC_RESTORE_MP)
              mp_regen_multiplier *= 1 + func.lvl.fdiv(100)
            end
          end
        end
      end

      if pc.inside_fort_zone? && (clan = pc.clan) && clan.fort_id > 0
        zone = ZoneManager.get_zone(pc, L2FortZone)
        pos_fort_idx = zone.try &.residence_id || -1
        fort_index = clan.fort_id
        if fort_index > 0 && fort_index == pos_fort_idx
          if fort = FortManager.get_fort_by_id(fort_index)
            if func = fort.get_function(Castle::FUNC_RESTORE_MP)
              mp_regen_multiplier *= 1 + func.lvl.fdiv(100)
            end
          end
        end
      end

      if pc.inside_mother_tree_zone?
        if zone = ZoneManager.get_zone(pc, L2MotherTreeZone)
          mp_regen_bonus += zone.mp_regen_bonus
        end
      end

      if pc.sitting?
        mp_regen_multiplier *= 1.5
      elsif !pc.moving?
        mp_regen_multiplier *= 1.1
      elsif pc.running?
        mp_regen_multiplier *= 0.7
      end

      init *= char.level_mod * BaseStats::MEN.calc_bonus(char)
    elsif char.is_a?(L2PetInstance)
      init = char.pet_level_data.pet_regen_mp * Config.pet_mp_regen_multiplier
    end

    (char.calc_stat(Stats::REGENERATE_MP_RATE, Math.max(init, 1)) * mp_regen_multiplier) + mp_regen_bonus
  end

  def cp_regen(pc : L2Character) : Float64
    init = pc.template.get_base_cp_regen(pc.level) * pc.level_mod * BaseStats::CON.calc_bonus(pc)
    cp_regen_multiplier = Config.cp_regen_multiplier

    if pc.sitting?
      cp_regen_multiplier *= 1.5
    elsif !pc.moving?
      cp_regen_multiplier *= 1.1
    elsif pc.running?
      cp_regen_multiplier *= 0.7
    end

    pc.calc_stat(REGENERATE_CP_RATE, Math.max(init, 1)) * cp_regen_multiplier
  end

  def festival_regen_modifier(pc : L2PcInstance) : Float64
    info = SevenSignsFestival.instance.get_festival_for_player(pc)
    oracle, festival_id = info
    if festival_id < 0
      return 0.0
    end

    if oracle == SevenSigns::CABAL_DAWN
      center = SevenSignsFestival::FESTIVAL_DAWN_PLAYER_SPAWNS[festival_id]
    else
      center = SevenSignsFestival::FESTIVAL_DUSK_PLAYER_SPAWNS[festival_id]
    end

    dist = pc.calculate_distance(center[0], center[1], 0, false, false)

    1.0 - (dist * 0.0005)
  end

  def cast_time(char : L2Character, skill : Skill) : Float64
    time = skill.hit_time.to_f64

    if !skill.channeling? || skill.channeling_skill_id == 0
      unless skill.static?
        speed = skill.magic? ? char.m_atk_spd : char.p_atk_spd
        time = (time / speed) * 333
      end

      if skill.magic?
        if char.charged_shot?(ShotType::SPIRITSHOTS) || char.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)
          time *= 0.6
        end
      end

      if time < 500 && skill.hit_time > 500
        time = 500.0
      end
    end

    time
  end

  def effect_success(attacker : L2Character, target : L2Character, skill : Skill) : Bool
    return false if target.door?
    return false if target.is_a?(L2SiegeFlagInstance)
    return false if target.is_a?(L2StaticObjectInstance)

    if skill.debuff? && target.debuff_blocked?
      sm = SystemMessage.c1_resisted_your_s2
      sm.add_char_name(target)
      sm.add_skill_name(skill)
      attacker.send_packet(sm)
      return false
    end

    activate_rate = skill.activate_rate
    return true if activate_rate == -1 || skill.basic_property.none?

    magic_level = skill.magic_level

    if magic_level <= -1
      magic_level = target.level + 3
    end

    case skill.basic_property
    when BaseStats::STR
      target_base_stat = target.str
    when BaseStats::DEX
      target_base_stat = target.dex
    when BaseStats::CON
      target_base_stat = target.con
    when BaseStats::INT
      target_base_stat = target.int
    when BaseStats::WIT
      target_base_stat = target.wit
    when BaseStats::MEN
      target_base_stat = target.men
    else
      target_base_stat = 0
    end

    base_mod = ((((((magic_level - target.level) + 3) * skill.lvl_bonus_rate) + activate_rate) + 30.0) - target_base_stat).to_f
    element_mod = attribute_bonus(attacker, target, skill)
    trait_mod = general_trait_bonus(attacker, target, skill.trait_type, false)
    buff_debuff_mod = 1 + (target.calc_stat(skill.debuff? ? DEBUFF_VULN : BUFF_VULN, 1) / 100)
    m_atk_mod = 1.0

    if skill.magic?
      m_atk = attacker.get_m_atk(nil, nil)
      val = 0.0
      if attacker.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)
        val = m_atk * 3
      end

      val += m_atk
      val = (Math.sqrt(val) / target.get_m_def(nil, nil)) * 11.0
      m_atk_mod = val
    end

    rate = base_mod * element_mod * trait_mod * m_atk_mod * buff_debuff_mod
    final_rate = trait_mod > 0 ? rate.clamp(skill.min_chance, skill.max_chance) : 0.0

    if final_rate <= Rnd.rand(100)
      if attacker.acting_player
        sm = SystemMessage.c1_resisted_your_s2
        sm.add_char_name(target)
        sm.add_skill_name(skill)
        attacker.send_packet(sm)
      end
      if (attacker.acting_player || target.acting_player).try &.gm?
        debug { "Failed #{skill} from #{attacker.name} against #{target.name} (#{final_rate.to_i}%)." }
      end
      return false
    end
    if (attacker.acting_player || target.acting_player).try &.gm?
      debug { "Landed #{skill} from #{attacker.name} against #{target.name} (#{final_rate.to_i}%)." }
    end
    true
  end

  def skill_mastery(actor : L2Character, sk : Skill) : Bool
    return false if sk.static? || !actor.player?

    val = actor.calc_stat(SKILL_CRITICAL, 0).to_i
    return false if val == 0

    init_val = 0.0
    case val
    when 1
      init_val = BaseStats::STR.calc_bonus(actor)
    when
      init_val = BaseStats::INT.calc_bonus(actor)
    else
      # [automatically added else]
    end

    init_val *= actor.calc_stat(SKILL_CRITICAL_PROBABILITY, 1)
    Rnd.rand(100) < init_val
  end

  def effect_abnormal_time(caster : L2Character, target : L2Character?, skill : Skill) : Int32
    time = skill.passive? || skill.toggle? ? -1 : skill.abnormal_time

    if target && target.servitor? && skill.abnormal_instant?
      time //= 2
    end

    if skill_mastery(caster, skill)
      time *= 2
    end

    if caster && target && skill.debuff?
      stat_mod = skill.basic_property.calc_bonus(target)
      res_mod = general_trait_bonus(caster, target, skill.trait_type, false)
      lvl_bonus_mod = lvl_bonus_mod(caster, target, skill)
      element_mod = attribute_bonus(caster, target, skill)
      time = (((time * res_mod * lvl_bonus_mod * element_mod) / stat_mod).clamp((time * 0.5), time)).ceil
    end

    time.to_i
  end

  def buff_debuff_reflection(target : L2Character, skill : Skill) : Bool
    return false if !skill.debuff? || skill.activate_rate == -1

    reflect_chance = target.calc_stat(skill.magic? ? REFLECT_SKILL_MAGIC : REFLECT_SKILL_PHYSIC, 0, nil, skill)
    reflect_chance > Rnd.rand(100)
  end

  def hit_miss(attacker : L2Character, target : L2Character) : Bool
    chance = ((80 + (2 * (attacker.accuracy - target.get_evasion_rate(attacker)))) * 10).to_i
    chance *= HitConditionBonusData.get_condition_bonus(attacker, target)
    chance.clamp(200, 980) < Rnd.rand(1000)
  end

  def shld_use(attacker : L2Character, target : L2Character, skill : Skill?) : Int8
    shld_use(attacker, target, skill, true)
  end

  def shld_use(attacker : L2Character, target : L2Character) : Int8
    shld_use(attacker, target, nil, true)
  end

  def shld_use(attacker : L2Character, target : L2Character, skill : Skill?, send_msg : Bool) : Int8
    item = target.secondary_weapon_item

    if !item || (!item.is_a?(L2Armor) || item.item_type == ArmorType::SIGIL)
      return 0i8
    end

    shld_rate = target.calc_stat(SHIELD_RATE, 0, attacker)
    shld_rate *= BaseStats::DEX.calc_bonus(target)
    return 0i8 if shld_rate <= 1e-6
    degree_side = target.calc_stat(SHIELD_DEFENCE_ANGLE, 0) + 120
    return 0i8 if degree_side < 360 && !target.facing?(attacker, degree_side.to_i)

    shld_success = SHIELD_DEFENSE_FAILED

    at_weapon = attacker.active_weapon_item

    if at_weapon && at_weapon.item_type == WeaponType::BOW
      shld_rate *= 1.3
    end

    if shld_rate > 0 && (100 - Config.alt_perfect_shld_block) < Rnd.rand(100)
      shld_success = SHIELD_DEFENSE_PERFECT_BLOCK
    elsif shld_rate > Rnd.rand(100)
      shld_success = SHIELD_DEFENSE_SUCCEED
    end

    if send_msg && target.player?
      case shld_success
      when SHIELD_DEFENSE_SUCCEED
        target.send_packet(SystemMessageId::SHIELD_DEFENCE_SUCCESSFULL)
      when SHIELD_DEFENSE_PERFECT_BLOCK
        target.send_packet(SystemMessageId::YOUR_EXCELLENT_SHIELD_DEFENSE_WAS_A_SUCCESS)
      else
        # [automatically added else]
      end
    end

    shld_success.to_i8
  end

  def crit(attacker : L2Character, target : L2Character) : Bool
    rate = attacker.calc_stat(CRITICAL_RATE_POS, attacker.stat.get_critical_hit(target, nil)).to_i
    target.calc_stat(DEFENCE_CRITICAL_RATE, rate) + target.calc_stat(DEFENCE_CRITICAL_RATE_ADD, 0) > Rnd.rand(1000)
  end

  def phys_dam(attacker : L2Character, target : L2Character, shld : Int8, crit : Bool, ss : Bool) : Float64
    defence = target.get_p_def(attacker)

    case shld
    when SHIELD_DEFENSE_SUCCEED
      unless Config.alt_game_shield_blocks
        defence += target.shld_def
      end
    when SHIELD_DEFENSE_PERFECT_BLOCK
      return 1.0
    else
      # [automatically added else]
    end

    pvp = attacker.playable? && target.playable?
    if attacker.behind_target?
      proximity_bonus = 1.2
    else
      if attacker.in_front_of_target?
        proximity_bonus = 1.0
      else
        proximity_bonus = 1.1
      end
    end
    damage : Float64 = attacker.get_p_atk(target)
    ss_boost = ss ? 2 : 1

    if pvp
      defence *= target.calc_stat(PVP_PHYSICAL_DEF)
    end

    damage *= ss_boost

    if crit
      a = 2 * attacker.calc_stat(CRITICAL_DAMAGE, 1, target)
      b = attacker.calc_stat(CRITICAL_DAMAGE_POS, 1, target)
      c = target.calc_stat(DEFENCE_CRITICAL_DAMAGE, 1, target)
      d = (76 * damage * proximity_bonus) / defence
      damage = a * b * c * d
      damage += (attacker.calc_stat(CRITICAL_DAMAGE_ADD, 0, target) * 77) / defence
      damage += target.calc_stat(DEFENCE_CRITICAL_DAMAGE_ADD, 0, target)
    else
      damage = (76 * damage * proximity_bonus) / defence
    end

    damage *= attack_trait_bonus(attacker, target)
    damage *= attacker.random_damage_multiplier

    if pvp
      damage *= attacker.calc_stat(PVP_PHYSICAL_DMG)
    end

    damage *= attribute_bonus(attacker, target, nil)

    if target.attackable?
      if !target.raid? && !target.raid_minion? && target.level >= Config.min_npc_lvl_dmg_penalty && attacker.acting_player && target.level - attacker.acting_player.not_nil!.level >= 2
        lvl_diff = target.level - attacker.acting_player.not_nil!.level - 1
        if crit
          if lvl_diff >= Config.npc_crit_dmg_penalty.size
            damage *= Config.npc_crit_dmg_penalty[Config.npc_crit_dmg_penalty.size - 1]
          else
            damage *= Config.npc_crit_dmg_penalty[lvl_diff]
          end
        else
          if lvl_diff >= Config.npc_dmg_penalty.size
            damage *= Config.npc_dmg_penalty[Config.npc_dmg_penalty.size - 1]
          else
            damage *= Config.npc_dmg_penalty[lvl_diff]
          end
        end
      end
    end

    Math.max(damage, 1.0)
  end

  def m_crit(rate : Float64) : Bool
    rate > Rnd.rand(1000)
  end

  def magic_dam(attacker : L2Character, target : L2Character, skill : Skill, shld : Int, sps : Bool, bss : Bool, mcrit : Bool, power : Float64) : Float64
    mdef = target.get_m_def(attacker, skill)
    case shld
    when SHIELD_DEFENSE_SUCCEED
      mdef += target.shld_def
    when SHIELD_DEFENSE_PERFECT_BLOCK
      return 1.0
    else
      # [automatically added else]
    end

    matk = attacker.get_m_atk(target, skill)
    pvp = attacker.playable? && target.playable?

    if pvp
      if skill.magic?
        mdef *= target.calc_stat(PVP_MAGICAL_DEF)
      else
        mdef *= target.calc_stat(PVP_PHYS_SKILL_DEF)
      end
    end

    matk *= bss ? 4 : sps ? 2 : 1

    damage = ((91 * Math.sqrt(matk)) / mdef) * power
    if Config.alt_game_magicfailures && !magic_success(attacker, target, skill)
      if attacker.player?
        if magic_success(attacker, target, skill) && target.level - attacker.level <= 9
          if skill.has_effect_type?(EffectType::HP_DRAIN)
            attacker.send_packet(SystemMessageId::DRAIN_HALF_SUCCESFUL)
          else
            attacker.send_packet(SystemMessageId::ATTACK_FAILED)
          end
          damage /= 2
        else
          sm = SystemMessage.c1_resisted_your_s2
          sm.add_char_name(target)
          sm.add_skill_name(skill)
          attacker.send_packet(sm)
          damage = 1.0
        end
      end
    elsif mcrit
      damage *= attacker.player? && target.player? ? 2.5 : 3
      damage *= attacker.calc_stat(MAGIC_CRIT_DMG)
    end

    damage *= attacker.random_damage_multiplier

    if pvp
      stat = skill.magic? ? PVP_MAGICAL_DMG : PVP_PHYS_SKILL_DMG
      damage *= attacker.calc_stat(stat)
    end

    damage *= attribute_bonus(attacker, target, skill)

    if target.attackable?
      if !target.raid? && !target.raid_minion?
        if target.level >= Config.min_npc_lvl_dmg_penalty
          if pc_attacker = attacker.acting_player
            if target.level - pc_attacker.level >= 2
              lvl_diff = target.level - pc_attacker.level - 1
              if lvl_diff >= Config.npc_skill_dmg_penalty.size
                damage *= Config.npc_skill_dmg_penalty[Config.npc_skill_dmg_penalty.size - 1]
              else
                damage *= Config.npc_skill_dmg_penalty[lvl_diff]
              end
            end
          end
        end
      end
    end

    damage
  end

  def magic_dam(attacker : L2CubicInstance, target : L2Character, skill : Skill, mcrit : Bool, shld : Int) : Float64
    mdef = target.get_m_def(attacker.owner, skill)

    case shld
    when SHIELD_DEFENSE_SUCCEED
      mdef += target.shld_def
    when SHIELD_DEFENSE_PERFECT_BLOCK
      return 1.0
    else
      # [automatically added else]
    end

    damage = (91.0 * attacker.cubic_power) / mdef

    owner = attacker.owner

    if Config.alt_game_magicfailures && !magic_success(owner, target, skill)
      if magic_success(owner, target, skill) && target.level - skill.magic_level <= 9
        if skill.has_effect_type?(EffectType::HP_DRAIN)
          owner.send_packet(SystemMessageId::DRAIN_HALF_SUCCESFUL)
        else
          owner.send_packet(SystemMessageId::ATTACK_FAILED)
        end
        damage /= 2
      else
        sm = SystemMessage.c1_resisted_your_s2
        sm.add_char_name(target)
        sm.add_skill_name(skill)
        owner.send_packet(sm)
        damage = 1.0
      end

      if target.player?
        if skill.has_effect_type?(EffectType::HP_DRAIN)
          sm = SystemMessage.resisted_c1_drain
          sm.add_char_name(owner)
          target.send_packet(sm)
        else
          sm = SystemMessage.resisted_c1_magic
          sm.add_char_name(owner)
          target.send_packet(sm)
        end
      end
    elsif mcrit
      damage *= 3
    end

    damage *= attribute_bonus(owner, target, skill)

    if target.attackable?
      damage *= attacker.owner.calc_stat(PVE_MAGICAL_DMG)
      if !target.raid? && !target.raid_minion?
        if target.level >= Config.min_npc_lvl_dmg_penalty
          if target.level - owner.level >= 2
            lvl_diff = target.level - owner.level - 1
            if lvl_diff >= Config.npc_skill_dmg_penalty.size
              damage *= Config.npc_skill_dmg_penalty[Config.npc_skill_dmg_penalty.size - 1]
            else
              damage *= Config.npc_skill_dmg_penalty[lvl_diff]
            end
          end
        end
      end
    end

    damage
  end

  def magic_success(attacker : L2Character, target : L2Character, skill : Skill) : Bool
    lvl_difference = target.level - (skill.magic_level > 0 ? skill.magic_level : attacker.level)
    lvl_modifier = 1.3 ** lvl_difference
    target_modifier = 1.0

    if target.attackable? && !target.raid? && !target.raid_minion?
      if target.level >= Config.min_npc_lvl_magic_penalty
        if attacker_pc = attacker.acting_player
          if target.level - attacker_pc.level >= 3
            lvl_diff = target.level - attacker_pc.level - 2
            if lvl_diff >= Config.npc_skill_chance_penalty.size
              target_modifier = Config.npc_skill_chance_penalty[Config.npc_skill_chance_penalty.size - 1]
            else
              target_modifier = Config.npc_skill_chance_penalty[lvl_diff]
            end
          end
        end
      end
    end

    res_modifier = target.calc_stat(MAGIC_SUCCESS_RES, 1, nil, skill)
    rate = 100 - (lvl_modifier * target_modifier * res_modifier).round
    Rnd.rand(100) < rate
  end

  def atk_break(target : L2Character, dmg : Float64) : Bool
    return false if target.channeling? || target.raid? || target.invul?
    init = 0.0

    if Config.alt_game_cancel_cast && target.casting_now?
      init = 15.0
    end

    if Config.alt_game_cancel_bow && target.attacking_now?
      if (wpn = target.active_weapon_item) && wpn.item_type == WeaponType::BOW
        init = 15.0
      end
    end

    return false if init <= 0

    init += Math.sqrt(13 * dmg)
    init -= (BaseStats::MEN.calc_bonus(target) * 100) - 100
    rate = target.calc_stat(ATTACK_CANCEL, init)
    Rnd.rand(100) < rate.clamp(1, 99)
  end

  def physical_skill_evasion(char : L2Character, target : L2Character, skill : Skill) : Bool
    return false if skill.magic? || skill.debuff?

    if Rnd.rand(100) < target.calc_stat(P_SKILL_EVASION, 0, nil, skill)
      if char.player?
        sm = SystemMessage.c1_dodges_attack
        sm.add_string(target.name)
        char.send_packet(sm)
      end

      if target.player?
        sm = SystemMessage.avoided_c1_attack2
        sm.add_string(char.name)
        target.send_packet(sm)
      end

      return true
    end

    false
  end

  def damage_reflected(attacker : L2Character, target : L2Character, skill : Skill, crit : Bool)
    return if skill.magic? || skill.cast_range > MELEE_ATTACK_RANGE

    chance = target.calc_stat(VENGEANCE_SKILL_PHYSICAL_DAMAGE, 0, target, skill)

    if Rnd.rand(100) < chance
      if target.player?
        sm = SystemMessage.countered_c1_attack
        sm.add_char_name(attacker)
        target.send_packet(sm)
      end

      if attacker.player?
        sm = SystemMessage.c1_performing_counterattack
        sm.add_char_name(target)
        attacker.send_packet(sm)
      end

      counter_dmg = ((target.get_p_atk(attacker) * 10.0) * 70.0) / attacker.get_p_def(target)
      counter_dmg *= weapon_trait_bonus attacker, target
      counter_dmg *= general_trait_bonus attacker, target, skill.trait_type, false
      counter_dmg *= attribute_bonus attacker, target, skill

      attacker.reduce_current_hp(counter_dmg, target, skill)

      if crit
        attacker.reduce_current_hp(counter_dmg, target, skill)
      end
    end
  end

  def probability(chance : Float64, attacker : L2Character, target : L2Character, skill : Skill) : Bool
    temp = ((((((skill.magic_level + chance) - target.level) + 30) - target.int) * attribute_bonus(attacker, target, skill)) * general_trait_bonus(attacker, target, skill.trait_type, false))
    Rnd.rand(100) < temp
  end

  def attribute_bonus(attacker : L2Character, target : L2Character, skill : Skill?) : Float64
    if skill
      if skill.attribute_type.none? || attacker.attack_element != skill.attribute_type.to_i
        return 1.0
      end

      attack_attribute = attacker.get_attack_element_value(attacker.attack_element) + skill.attribute_power
    else
      attack_attribute = attacker.get_attack_element_value(attacker.attack_element)
      return 1.0 if attack_attribute == 0
    end

    defense_attribute = target.get_defense_element_value(attacker.attack_element)
    if attack_attribute <= defense_attribute
      return 1.0
    end

    attack_attribute_mod = 0.0
    defense_attribute_mod = 0.0

    if attack_attribute >= 450
      if defense_attribute >= 450
        attack_attribute_mod = 0.06909
        defense_attribute_mod = 0.078
      elsif defense_attribute >= 350
        attack_attribute_mod = 0.0887
        defense_attribute_mod = 0.1007
      else
        attack_attribute_mod = 0.129
        defense_attribute_mod = 0.1473
      end
    elsif attack_attribute >= 300
      if defense_attribute >= 300
        attack_attribute_mod = 0.0887
        defense_attribute_mod = 0.1007
      elsif defense_attribute >= 150
        attack_attribute_mod = 0.129
        defense_attribute_mod = 0.1473
      else
        attack_attribute_mod = 0.25
        defense_attribute_mod = 0.2894
      end
    elsif attack_attribute >= 150
      if defense_attribute >= 150
        attack_attribute_mod = 0.129
        defense_attribute_mod = 0.1473
      elsif defense_attribute >= 0
        attack_attribute_mod = 0.25
        defense_attribute_mod = 0.2894
      else
        attack_attribute_mod = 0.4
        defense_attribute_mod = 0.55
      end
    elsif attack_attribute >= -99
      if defense_attribute >= 0
        attack_attribute_mod = 0.25
        defense_attribute_mod = 0.2894
      else
        attack_attribute_mod = 0.4
        defense_attribute_mod = 0.55
      end
    else
      if defense_attribute >= 450
        attack_attribute_mod = 0.06909
        defense_attribute_mod = 0.078
      elsif defense_attribute >= 350
        attack_attribute_mod = 0.0887
        defense_attribute_mod = 0.1007
      else
        attack_attribute_mod = 0.129
        defense_attribute_mod = 0.1473
      end
    end

    attribute_diff = attack_attribute - defense_attribute

    if attribute_diff >= 300
      max = 100.0
      min = -50.0
    elsif attribute_diff >= 150
      max = 70.0
      min = -50.0
    elsif attribute_diff >= -150
      max = 40.0
      min = -50.0
    elsif attribute_diff >= -300
      max = 40.0
      min = -60.0
    else
      max = 40.0
      min = -80.0
    end

    attack_attribute += 100
    attack_attribute *= attack_attribute

    attack_attribute_mod = (attack_attribute / 144.0) * attack_attribute_mod

    defense_attribute += 100
    defense_attribute *= defense_attribute

    defense_attribute_mod = (defense_attribute / 169.0) * defense_attribute_mod

    attribute_mod_diff = attack_attribute_mod - defense_attribute_mod

    attribute_mod_diff = attribute_mod_diff.clamp(min, max)

    result = (attribute_mod_diff / 100.0) + 1

    if attacker.player? && target.player? && result < 1.0
      result = 1.0
    end

    result
  end

  def general_trait_bonus(attacker : L2Character, target : L2Character, trait_type : TraitType, ignore_res : Bool) : Float64
    return 1.0 if trait_type.none?

    return 0.0 if target.stat.trait_invul?(trait_type)
    case trait_type.type
    when 2
      if !attacker.stat.has_attack_trait?(trait_type) || !target.stat.has_defence_trait?(trait_type)
        return 1.0
      end
    when 3
      return 1.0 if ignore_res
    else
      return 1.0
    end


    result = (attacker.stat.get_attack_trait(trait_type).to_f - target.stat.get_defence_trait(trait_type)) + 1.0
    result.clamp(0.05, 2.0)
  end

  def mana_dam(attacker : L2Character, target : L2Character, skill : Skill, shld : Int, sps : Bool, bss : Bool, mcrit : Bool, power : Float64) : Float64
    m_atk = attacker.get_m_atk(target, skill)
    m_def = target.get_m_def(attacker, skill)
    mp = target.max_mp.to_f

    case shld
    when SHIELD_DEFENSE_SUCCEED
      m_def += target.shld_def
    when SHIELD_DEFENSE_PERFECT_BLOCK
      return 1.0
    else
      # [automatically added else]
    end

    m_atk *= bss ? 4 : sps ? 2 : 1

    damage = (Math.sqrt(m_atk) * power * (mp / 97)) / m_def
    damage *= general_trait_bonus(attacker, target, skill.trait_type, false)

    if target.attackable?
      if !target.raid? && !target.raid_minion?
        if target.level >= Config.min_npc_lvl_dmg_penalty
          if pc_attacker = attacker.acting_player
            if target.level - pc_attacker.level >= 2
              lvl_diff = target.level - pc_attacker.level - 1
              if lvl_diff >= Config.npc_skill_dmg_penalty.size
                damage *= Config.npc_skill_dmg_penalty[Config.npc_skill_dmg_penalty.size - 1]
              else
                damage *= Config.npc_skill_dmg_penalty[lvl_diff]
              end
            end
          end
        end
      end
    end

    if Config.alt_game_magicfailures && !magic_success(attacker, target, skill)
      if attacker.player?
        sm = SystemMessage.damage_decreased_because_c1_resisted_c2_magic
        sm.add_char_name(target)
        sm.add_char_name(attacker)
        attacker.send_packet(sm)
        damage /= 2
      end

      if target.player?
        sm = SystemMessage.c1_weakly_resisted_c2_magic
        sm.add_char_name(target)
        sm.add_char_name(attacker)
        target.send_packet(sm)
      end
    end

    if mcrit
      damage *= 3
      attacker.send_packet(SystemMessageId::CRITICAL_HIT_MAGIC)
    end

    damage
  end

  def magic_affected(actor : L2Character, target : L2Character, skill : Skill) : Bool
    defence = 0.0

    if skill.active? && skill.bad?
      defence = target.get_m_def(actor, skill)
    end

    attack = 2.0 * actor.get_m_atk(target, skill)
    attack *= general_trait_bonus(actor, target, skill.trait_type, false)
    d = (attack - defence).fdiv(attack + defence)

    if skill.debuff? && target.debuff_blocked?
      return false
    end

    d += 0.5 * Rnd.gaussian

    d > 0
  end

  def cubic_skill_success(attacker : L2CubicInstance, target : L2Character, skill : Skill, shld : Int) : Bool
    if skill.debuff? && target.debuff_blocked?
      return false
    end

    if shld == SHIELD_DEFENSE_PERFECT_BLOCK
      return false
    end

    if buff_debuff_reflection(target, skill)
      return false
    end

    base_rate = skill.activate_rate
    stat_mod = skill.basic_property.calc_bonus(target)
    rate = base_rate / stat_mod

    res_mod = general_trait_bonus(attacker.owner, target, skill.trait_type, false)
    rate *= res_mod

    lvl_mod = lvl_bonus_mod(attacker.owner, target, skill)
    rate *= lvl_mod

    element_mod = attribute_bonus(attacker.owner, target, skill)
    rate *= element_mod

    final_rate = rate.clamp(skill.min_chance, skill.max_chance)

    Rnd.rand(100) < final_rate
  end

  def blow_damage(attacker : L2Character, target : L2Character, skill : Skill, shld : Int, ss : Bool, power : Float64) : Float64
    defence = target.get_p_def(attacker)
    case shld
    when SHIELD_DEFENSE_SUCCEED
      defence += target.shld_def
    when SHIELD_DEFENSE_PERFECT_BLOCK
      return 1.0
    else
      # [automatically added else]
    end

    pvp = attacker.playable? && target.playable?
    damage = 0.0
    proximity_bonus = attacker.behind_target? ? 1.2 : attacker.in_front_of_target? ? 1.0 : 1.1
    ss_boost = ss ? 1.458 : 1.0
    pvp_bonus = 1.0

    if pvp
      pvp_bonus = attacker.calc_stat(PVP_PHYS_SKILL_DMG)
      defence *= target.calc_stat(PVP_PHYS_SKILL_DEF)
    end

    base_mod = (77.0 * (power + (attacker.get_p_atk(target) * ss_boost))) / defence
    critical_mod = attacker.calc_stat(CRITICAL_DAMAGE, 1, target, skill)
    critical_mod_pos = ((attacker.calc_stat(CRITICAL_DAMAGE_POS, 1, target, skill) - 1) / 2) + 1
    critical_vuln_mod = target.calc_stat(DEFENCE_CRITICAL_DAMAGE, 1, target, skill)
    critical_add_mod = (attacker.calc_stat(CRITICAL_DAMAGE_ADD, 0) * 6.1 * 77) / defence
    critical_add_vuln = target.calc_stat(DEFENCE_CRITICAL_DAMAGE_ADD, 0, target, skill)

    weapon_trait_mod = weapon_trait_bonus(attacker, target)
    general_trait_mod = general_trait_bonus(attacker, target, skill.trait_type, false)
    attribute_mod = attribute_bonus(attacker, target, skill)
    weapon_mod = attacker.random_damage_multiplier

    penalty_mod = 1.0
    if target.is_a?(L2Attackable) && !target.raid? && !target.raid_minion?
      if target.level >= Config.min_npc_lvl_dmg_penalty
        if (pc = attacker.acting_player) && target.level - pc.level >= 2
          lvl_diff = target.level - pc.level - 1
          if lvl_diff >= Config.npc_skill_dmg_penalty.size
            penalty_mod *= Config.npc_skill_dmg_penalty[Config.npc_skill_dmg_penalty.size - 1]
          else
            penalty_mod *= Config.npc_skill_dmg_penalty[lvl_diff]
          end
        end
      end
    end

    damage = (base_mod * critical_mod * critical_mod_pos * critical_vuln_mod * proximity_bonus * pvp_bonus) + critical_add_mod + critical_add_vuln
    damage *= weapon_trait_mod
    damage *= general_trait_mod
    damage *= attribute_mod
    damage *= weapon_mod
    damage *= penalty_mod

    Math.max(damage, 1.0)
  end

  def blow_success(char : L2Character, target : L2Character, skill : Skill, blow_chance : Int32) : Bool
    dex_mod = BaseStats::DEX.calc_bonus(char)
    side_mod = char.in_front_of_target? ? 1 : char.behind_target? ? 2 : 1.5
    base_rate = blow_chance * dex_mod * side_mod
    rate = char.calc_stat(BLOW_RATE, base_rate, target)
    result = Rnd.rand(100) < rate
    if (char.acting_player || target.acting_player).try &.gm?
      tmp = result ? "landed" : "missed"
      debug { "Blow from #{char.name} against #{target.name} #{tmp} (chance: #{rate}%)." }
    end
    if !result && (pc = char.acting_player)
      pc.send_packet(SystemMessageId::ATTACK_FAILED)
    end
    result
  end

  def weapon_trait_bonus(attacker : L2Character, target : L2Character) : Float64
    type = attacker.attack_type.trait_type
    result = target.stat.defence_traits[type.to_i] - 1.0
    1.0 - result
  end

  def steal_effects(char : L2Character, target : L2Character, skill : Skill, slot : DispelCategory, rate, max) : Enumerable(BuffInfo)
    cancelled = [] of BuffInfo

    case slot
    when .buff?
      cancel_magic_lvl = skill.magic_level
      vuln = target.calc_stat(CANCEL_VULN, 0, target)
      prof = char.calc_stat(CANCEL_PROF, 0, target)
      res_mod = 1.0 + (((vuln + prof) * -1) / 100)
      final_rate = (rate / res_mod).to_i

      effect_list = target.effect_list
      temp = [] of BuffInfo
      temp.concat(effect_list.buffs) if effect_list.has_buffs?
      temp.concat(effect_list.triggered) if effect_list.has_triggered?
      temp.concat(effect_list.dances) if effect_list.has_dances?
      temp.each do |info|
        next unless info.skill.can_be_stolen?
        unless cancel_success(info, cancel_magic_lvl, final_rate, skill)
          next
        end
        cancelled << info
        break if cancelled.size >= max
      end
    when .debuff?
      target.effect_list.debuffs.each do |info|
        if info.skill.debuff? && !info.skill.irreplaceable_buff?
          if Rnd.rand(100) <= rate
            cancelled << info
            break if cancelled.size >= max
          end
        end
      end
    else
      # [automatically added else]
    end

    cancelled
  end

  def cancel_success(info : BuffInfo, cancel_magic_lvl : Int32, rate : Int32, skill : Skill) : Bool
    if info.skill.magic_level > 0
      rate *= 1 + ((cancel_magic_lvl - info.skill.magic_level) / 100)
    end

    Rnd.rand(100) < rate.clamp(skill.min_chance, skill.max_chance)
  end

  def skill_resurrect_restore_percent(base : Float64, caster : L2Character) : Float64
    if base == 0 || base == 100
      return base
    end

    percent = base * BaseStats::WIT.calc_bonus(caster)
    if percent - base > 20
      percent += 20
    end

    percent = Math.max(percent, base)
    Math.min(percent, 90.0)
  end

  def attack_trait_bonus(attacker : L2Character, target : L2Character) : Float64
    weapon_trait_bonus = weapon_trait_bonus(attacker, target)

    return 0.0 if weapon_trait_bonus == 0

    weakness_bonus = 1.0

    TraitType.each do |type|
      if type.type == 2
        weakness_bonus *= general_trait_bonus(attacker, target, type, true)
        return 0.0 if weakness_bonus == 0
      end
    end

    (weapon_trait_bonus * weakness_bonus).clamp(0.05, 2.0)
  end

  def lvl_bonus_mod(attacker : L2Character, target : L2Character, skill : Skill) : Float64
    attacker_lvl = skill.magic_level > 0 ? skill.magic_level : attacker.level
    rate_mod = 1.0 + (skill.lvl_bonus_rate.fdiv 100)
    lvl_mod = 1.0 + ((attacker_lvl - target.level).fdiv 100)
    rate_mod * lvl_mod
  end

  def backstab_damage(attacker : L2Character, target : L2Character, skill : Skill, shld : Int8, ss : Bool, power : Float64) : Float64
    defence = target.get_p_def(attacker)

    case shld
    when SHIELD_DEFENSE_SUCCEED
      defence += target.shld_def
    when SHIELD_DEFENSE_PERFECT_BLOCK
      return 1.0
    else
      # [automatically added else]
    end

    pvp = attacker.playable? && target.playable?
    damage = 0.0
    proximity_bonus = attacker.behind_target? ? 1.2 : attacker.in_front_of_target? ? 1.0 : 1.1
    ss_boost = ss ? 1.458 : 1.0
    pvp_bonus = 1.0

    if pvp
      pvp_bonus = attacker.calc_stat(PVP_PHYS_SKILL_DMG)
      defence *= target.calc_stat(PVP_PHYS_SKILL_DEF)
    end

    base_mod = (77.0 * (power + (attacker.get_p_atk(target))) / defence) * ss_boost
    critical_mod = attacker.calc_stat(CRITICAL_DAMAGE, 1, target, skill)
    critical_mod_pos = ((attacker.calc_stat(CRITICAL_DAMAGE_POS, 1, target, skill) - 1) / 2) + 1
    critical_vuln_mod = target.calc_stat(DEFENCE_CRITICAL_DAMAGE, 1, target, skill)
    critical_add_mod = (attacker.calc_stat(CRITICAL_DAMAGE_ADD, 0) * 6.1 * 77) / defence
    critical_add_vuln = target.calc_stat(DEFENCE_CRITICAL_DAMAGE_ADD, 0, target, skill)

    weapon_trait_mod = weapon_trait_bonus(attacker, target)
    general_trait_mod = general_trait_bonus(attacker, target, skill.trait_type, false)
    attribute_mod = attribute_bonus(attacker, target, skill)
    weapon_mod = attacker.random_damage_multiplier

    penalty_mod = 1.0
    if target.attackable? && !target.raid? && !target.raid_minion?
      if target.level >= Config.min_npc_lvl_dmg_penalty
        if attacker.acting_player
          if target.level - attacker.acting_player.not_nil!.level >= 2
            lvl_diff = target.level - attacker.acting_player.not_nil!.level - 1
            if lvl_diff >= Config.npc_skill_dmg_penalty.size
              penalty_mod *= Config.npc_skill_dmg_penalty[Config.npc_skill_dmg_penalty.size - 1]
            else
              penalty_mod *= Config.npc_skill_dmg_penalty[lvl_diff]
            end
          end
        end
      end
    end

    damage = (base_mod * critical_mod * critical_mod_pos * critical_vuln_mod * proximity_bonus * pvp_bonus) + critical_add_mod + critical_add_vuln
    damage *= weapon_trait_mod
    damage *= general_trait_mod
    damage *= attribute_mod
    damage *= weapon_mod
    damage *= penalty_mod

    Math.max(damage, 1.0)
  end

  def karma_lost(pc : L2PcInstance, exp : Int64) : Int32
    mul = KarmaData.get_multiplier(pc.level)
    if exp > 0
      exp /= Config.rate_karma_lost
    end
    (exp / mul / 30).abs.to_i
  end

  def karma_gain(pk_count : Int32, is_summon : Bool) : Int32
    result = 43_200

    if is_summon
      result = (((((pk_count * 0.375) + 1) * 60) * 4) - 150).to_i
      return 10_800 if result > 10_800
    end

    if pk_count < 99
      ((((pk_count * 0.5) + 1) * 60) * 12).to_i
    elsif pk_count < 180
      ((((pk_count * 0.125) + 37.75) * 60) * 12).to_i
    else
      result
    end
  end

  def siege_regen_modifier(pc : L2PcInstance) : Float64
    return 0.0 unless clan = pc.clan

    siege = SiegeManager.get_siege(*pc.xyz)
    return 0.0 unless siege && siege.in_progress?

    return 0.0 unless siege_clan = siege.get_attacker_clan(clan.id)
    return 0.0 unless flag = siege_clan.flag[0]?
    return 0.0 unless Util.in_range?(200, pc, flag, true)

    1.5
  end

  def fall_dam(char : L2Character, fall_height : Int32) : Float64
    unless Config.enable_falling_damage && fall_height >= 0
      return 0.0
    end

    char.calc_stat(FALL, (fall_height * char.max_hp) / 1000.0)
  end

  def skill_phys_dam(attacker : L2Character, target : L2Character, skill : Skill, shld : Int8, crit : Bool, ss : Bool, power : Float64) : Float64
    defence = target.get_p_def(attacker)

    case shld
    when SHIELD_DEFENSE_SUCCEED
      unless Config.alt_game_shield_blocks
        defence += target.shld_def
      end
    when SHIELD_DEFENSE_PERFECT_BLOCK
      return 1.0
    else
      # [automatically added else]
    end

    pvp = attacker.playable? && target.playable?
    if attacker.behind_target?
      proximity_bonus = 1.2
    else
      if attacker.in_front_of_target?
        proximity_bonus = 1.0
      else
        proximity_bonus = 1.1
      end
    end

    damage = 0.0
    ss_boost = ss ? 2 : 1
    pvp_bonus = 1.0

    if pvp
      pvp_bonus = attacker.calc_stat(PVP_PHYS_SKILL_DMG)
      defence *= target.calc_stat(PVP_PHYS_SKILL_DEF)
    end

    base_mod = (77.0 * (power + (attacker.get_p_atk(target) * ss_boost))) / defence
    penalty_mod = 1.0

    if target.is_a?(L2Attackable) && !target.raid? && !target.raid_minion?
      if target.level >= Config.min_npc_lvl_dmg_penalty
        if attacker.acting_player
          if target.level - attacker.acting_player.not_nil!.level >= 2
            lvl_diff = target.level - attacker.acting_player.not_nil!.level - 1
            if lvl_diff >= Config.npc_skill_dmg_penalty.size
              penalty_mod *= Config.npc_skill_dmg_penalty[Config.npc_skill_dmg_penalty.size - 1]
            else
              penalty_mod *= Config.npc_skill_dmg_penalty[lvl_diff]
            end

            if crit
              if lvl_diff >= Config.npc_crit_dmg_penalty.size
                penalty_mod *= Config.npc_crit_dmg_penalty[Config.npc_crit_dmg_penalty.size - 1]
              else
                penalty_mod *= Config.npc_crit_dmg_penalty[lvl_diff]
              end
            else
              if lvl_diff >= Config.npc_dmg_penalty.size
                penalty_mod *= Config.npc_dmg_penalty[Config.npc_dmg_penalty.size - 1]
              else
                penalty_mod *= Config.npc_dmg_penalty[lvl_diff]
              end
            end
          end
        end
      end
    end

    damage = base_mod * proximity_bonus * pvp_bonus
    damage *= attack_trait_bonus(attacker, target)
    damage *= attribute_bonus(attacker, target, skill)
    damage *= attacker.random_damage_multiplier
    damage *= penalty_mod
    damage = attacker.calc_stat(PHYSICAL_SKILL_POWER, damage)

    Math.max(damage, 1.0)
  end

  def skill_crit(attacker : L2Character, target : L2Character, crit_chance : Int32) : Bool
    BaseStats::STR.calc_bonus(attacker) * crit_chance > Rnd.rand * 100
  end

  def soul_bonus(skill : Skill, info : BuffInfo) : Float64
    skill.max_soul_consume_count > 0 ? (info.charges * 0.04) + 1 : 1.0
  end
end
