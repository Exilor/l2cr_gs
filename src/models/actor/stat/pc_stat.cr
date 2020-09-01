require "./playable_stat"

class PcStat < PlayableStat
  include Packets::Outgoing

  VITALITY_LEVELS = {240, 2_000, 13_000, 17_000, 20_000}
  MAX_VITALITY_POINTS = VITALITY_LEVELS[4]
  MIN_VITALITY_POINTS = 1

  @old_max_hp = 0
  @old_max_mp = 0
  @old_max_cp = 0
  @vitality_points = 1f32
  @talisman_slots = Atomic(Int32).new(0)
  @cloak_slot = false

  getter vitality_level = 0i8
  getter starting_exp = 0i64
  property max_cubic_count = 1

  def starting_exp=(value : Int64)
    if Config.bot_report_enable
      @starting_exp = value
    end
  end

  def talisman_slots : Int32
    @talisman_slots.get
  end

  def add_talisman_slots(count : Int32)
    @talisman_slots.add(count)
  end

  def can_equip_cloak? : Bool
    @cloak_slot
  end

  def cloak_slot_status=(@cloak_slot : Bool)
  end

  def max_cp : Int32
    pc = active_char
    val = pc.template.get_base_cp_max(pc.level)
    val = calc_stat(MAX_CP, val).to_i

    if val != @old_max_cp
      @old_max_cp = val

      if pc.current_cp != val
        # The 'false' arg prevents an issue where #broadcast_status_update
        # from L2PcInstance would freeze the client.
        pc.set_current_cp(pc.current_cp, false)
      end
    end

    val
  end

  def max_hp : Int32
    pc = active_char
    val = pc.template.get_base_hp_max(pc.level)
    val = calc_stat(MAX_HP, val).to_i

    if val != @old_max_hp
      @old_max_hp = val

      if pc.current_hp != val
        # The 'false' arg prevents an issue where #broadcast_status_update
        # from L2PcInstance would freeze the client.
        pc.set_current_hp(pc.current_hp, false)
      end
    end

    val
  end

  def max_mp : Int32
    pc = active_char
    val = pc.template.get_base_mp_max(pc.level)
    val = calc_stat(MAX_MP, val).to_i

    if val != @old_max_mp
      @old_max_mp = val

      if pc.current_mp != val
        # Rhe 'false' arg prevents an issue where #broadcast_status_update
        # from L2PcInstance would freeze the client.
        pc.set_current_mp(pc.current_mp, false)
      end
    end

    val
  end

  def get_base_move_speed(type) : Float64
    pc = active_char

    if pc.transformed?
      if template = pc.transformation.try &.get_template(pc)
        return template.get_base_move_speed(type)
      end
    elsif pc.mounted?
      data = PetDataTable.get_pet_level_data(pc.mount_npc_id, pc.mount_level)
      if data
        return data.get_speed_on_ride(type)
      end
    end

    super
  end

  def run_speed : Float64
    pc = active_char
    val = super + Config.run_spd_boost

    if val > Config.max_run_speed && !pc.override_max_stats_value?
      return Config.max_run_speed.to_f
    end

    if pc.mounted?
      if pc.mount_level &- pc.level >= 10
        val /= 2
      end

      if pc.hungry?
        val /= 2
      end
    end

    val
  end

  def walk_speed : Float64
    pc = active_char
    val = super + Config.run_spd_boost

    if val > Config.max_run_speed && !pc.override_max_stats_value?
      return Config.max_run_speed.to_f
    end

    if pc.mounted?
      if pc.mount_level &- pc.level >= 10
        val /= 2
      end

      if pc.hungry?
        val /= 2
      end
    end

    val
  end

  def p_atk_spd : Float64
    if active_char.override_max_stats_value?
      return super
    end

    Math.min(super, Config.max_patk_speed).to_f
  end

  def update_vitality_level(quiet : Bool)
    level = (0..3).find { |i| @vitality_points <= VITALITY_LEVELS[i] } || 4

    if !quiet && level != @vitality_level
      if level < @vitality_level
        active_char.send_packet(SystemMessageId::VITALITY_HAS_DECREASED)
      else
        active_char.send_packet(SystemMessageId::VITALITY_HAS_INCREASED)
      end

      if level == 0
        active_char.send_packet(SystemMessageId::VITALITY_IS_EXHAUSTED)
      elsif level == 4
        active_char.send_packet(SystemMessageId::VITALITY_IS_AT_MAXIMUM)
      end
    end

    @vitality_level = level.to_i8
  end

  def vitality_points : Int32
    @vitality_points.to_i
  end

  def set_vitality_points(points : Int32, quiet : Bool)
    return if points == @vitality_points
    points = points.clamp(MIN_VITALITY_POINTS, MAX_VITALITY_POINTS).to_f
    @vitality_points = points.to_f32
    update_vitality_level(quiet)
    active_char.send_packet(ExVitalityPointInfo.new(@vitality_points.to_i32))
  end

  def update_vitality_points(points : Float32, use_rates : Bool, quiet : Bool)
    sync do
      if points == 0 || !Config.enable_vitality
        return
      end

      points = points.to_f64

      if use_rates
        return if active_char.lucky?

        if points < 0
          stat = calc_stat(VITALITY_CONSUME_RATE, 1, @active_char).to_i
          return if stat == 0
          points = -points if stat < 0
        end

        if points > 0
          points *= Config.rate_vitality_gain
        else
          points *= Config.rate_vitality_lost
        end
      end

      if points > 0
        points = Math.min(@vitality_points + points, MAX_VITALITY_POINTS)
      else
        points = Math.max(@vitality_points + points, MIN_VITALITY_POINTS)
      end

      return if (points - @vitality_points).abs <= 1e-6

      @vitality_points = points.to_f32
      update_vitality_level(quiet)
    end
  end

  def vitality_multiplier : Float64
    if Config.enable_vitality
      case @vitality_level
      when 1
        return Config.rate_vitality_level_1.to_f
      when 2
        return Config.rate_vitality_level_2.to_f
      when 3
        return Config.rate_vitality_level_3.to_f
      when 4
        return Config.rate_vitality_level_4.to_f
      end
    end

    1.0
  end

  def exp_bonus_multiplier : Float64
    bonus = vitality = nevits = hunting = bonus_exp = 1.0
    vitality = vitality_multiplier
    nevits = RecoBonus.get_reco_multiplier(active_char)
    bonus_exp = 1.0 + (calc_stat(BONUS_EXP, 0) / 100)

    bonus += vitality - 1 if vitality > 1
    bonus += nevits   - 1 if nevits   > 1
    bonus += hunting  - 1 if hunting  > 1
    bonus += bonus_exp - 1 if bonus_exp > 1

    bonus.clamp(1, Config.max_bonus_exp).to_f
  end

  def sp_bonus_multiplier : Float64
    bonus = vitality = nevits = hunting = bonus_sp = 1.0
    vitality = vitality_multiplier
    nevits = RecoBonus.get_reco_multiplier(active_char)
    bonus_sp = 1.0 + (calc_stat(BONUS_SP, 0) / 100)

    bonus += vitality - 1 if vitality > 1
    bonus += nevits   - 1 if nevits   > 1
    bonus += hunting  - 1 if hunting  > 1
    bonus += bonus_sp - 1 if bonus_sp > 1

    bonus.clamp(1, Config.max_bonus_sp).to_f
  end

  def max_level : Int32
    pc = active_char
    pc.subclass_active? ? Config.max_subclass_level : Config.max_player_level
  end

  def max_exp_level : Int32
    if active_char.subclass_active?
      Config.max_subclass_level &+ 1
    else
      Config.max_player_level &+ 1
    end
  end

  def active_char : L2PcInstance
    super.as(L2PcInstance)
  end
end
