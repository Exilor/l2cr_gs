class Packets::Outgoing::PetInfo < GameServerPacket
  @summoned : Bool
  @x : Int32
  @y : Int32
  @z : Int32
  @heading : Int32
  @m_atk_spd : Int32
  @p_atk_spd : Int32
  @run_spd : Int32
  @walk_spd : Int32
  @swim_run_spd : Int32
  @swim_walk_spd : Int32
  @fly_run_spd : Int32
  @fly_walk_spd : Int32
  @move_multiplier : Float64
  @max_hp : Int32
  @max_mp : Int32
  @max_fed = 0
  @cur_fed = 0

  def initialize(summon : L2Summon, val : Int32)
    @summon = summon
    @val = val
    @summoned = summon.show_summon_animation?
    @x, @y, @z = summon.xyz
    @heading = summon.heading
    @m_atk_spd = summon.m_atk_spd
    @p_atk_spd = summon.p_atk_spd.to_i
    @move_multiplier = summon.movement_speed_multiplier
    @run_spd = (summon.run_speed / @move_multiplier).round.to_i
    @walk_spd = (summon.walk_speed / @move_multiplier).round.to_i
    @swim_run_spd = (summon.swim_run_speed / @move_multiplier).round.to_i
    @swim_walk_spd = (summon.swim_walk_speed / @move_multiplier).round.to_i
    @fly_run_spd = summon.flying? ? @run_spd : 0
    @fly_walk_spd = summon.flying? ? @walk_spd : 0
    @max_hp = summon.max_hp
    @max_mp = summon.max_mp

    if summon.is_a?(L2PetInstance)
      @cur_fed = summon.current_feed
      @max_fed = summon.max_fed
    elsif summon.is_a?(L2ServitorInstance)
      @cur_fed = summon.life_time_remaining
      @max_fed = summon.life_time
    end
  end

  private def write_impl
    c 0xb2

    d @summon.summon_type
    d @summon.l2id
    d @summon.template.display_id &+ 1_000_000
    d 0 # 1 -> attackable
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
    f @summon.attack_speed_multiplier
    f @summon.template.f_collision_radius
    f @summon.template.f_collision_height

    d @summon.weapon
    d @summon.armor
    d 0x00

    c @summon.owner ? 1 : 0
    c @summon.running? ? 1 : 0
    c @summon.in_combat? ? 1 : 0
    c @summon.looks_dead? ? 1 : 0
    c @summoned ? 2 : @val

    d -1

    if @summon.pet?
      s @summon.name
    else
      s @summon.template.using_server_side_name? ? @summon.name : ""
    end

    d -1
    s @summon.title

    d 1
    d @summon.pvp_flag
    d @summon.karma
    d @cur_fed
    d @max_fed
    d @summon.current_hp
    d @max_hp
    d @summon.current_mp
    d @max_mp
    d @summon.stat.sp
    d @summon.level

    q @summon.stat.exp

    if @summon.exp_for_this_level > @summon.stat.exp
      q @summon.stat.exp
    else
      q @summon.exp_for_this_level
    end

    q @summon.exp_for_this_level

    d @summon.pet? ? @summon.inventory.total_weight : 0
    d @summon.max_load
    d @summon.get_p_atk(nil).to_i
    d @summon.get_p_def(nil).to_i
    d @summon.get_m_atk(nil, nil).to_i
    d @summon.get_m_def(nil, nil).to_i
    d @summon.accuracy
    d @summon.get_evasion_rate(nil)
    d @summon.get_critical_hit(nil, nil)
    d @summon.move_speed.to_i
    d @summon.p_atk_spd.to_i
    d @summon.m_atk_spd
    d @summon.abnormal_visual_effects

    h @summon.mountable? ? 1 : 0

    c @summon.inside_water_zone? ? 1 : @summon.flying? ? 2 : 0

    h 0x00 # unknown

    c @summon.team.to_i

    d @summon.soulshots_per_hit
    d @summon.spiritshots_per_hit
    d @summon.form_id
    d @summon.abnormal_visual_effects_special
  end
end
