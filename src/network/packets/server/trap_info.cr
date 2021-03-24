class Packets::Outgoing::TrapInfo < Packets::Outgoing::AbstractNpcInfo
  @id_template : Int32
  @attackable = false
  @r_hand : Int32
  @l_hand : Int32

  def initialize(trap : L2TrapInstance, attacker : L2Character?)
    @trap = trap

    super(trap)

    @id_template = trap.template.display_id
    if attacker
      @attackable = trap.auto_attackable?(attacker)
    end
    @r_hand = 0
    @l_hand = 0
    @collision_height = trap.template.f_collision_height
    @collision_radius = trap.template.f_collision_radius
    if trap.template.using_server_side_name?
      @name = trap.name
    end
    @title = trap.owner.try &.name || ""
  end

  private def write_impl
    c 0x0c

    d @trap.l2id
    d @id_template &+ 1_000_000
    d @attackable ? 1 : 0
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
    f @trap.attack_speed_multiplier
    f @collision_radius
    f @collision_height
    d @r_hand
    d @chest
    d @l_hand
    c 1
    c 1
    c @trap.in_combat? ? 1 : 0
    c @trap.looks_dead? ? 1 : 0
    c @summoned ? 2 : 0
    d -1
    s @name
    d -1
    s @title
    d 0

    d @trap.pvp_flag
    d @trap.karma

    if @trap.invisible?
      d @trap.abnormal_visual_effects | AbnormalVisualEffect::STEALTH.mask
    else
      d @trap.abnormal_visual_effects
    end
    d 0
    d 0
    d 0
    d 0
    c 0

    c @trap.team.to_i

    f @collision_radius
    f @collision_height
    d 0
    d 0
    d 0
    d 0
    c 1
    c 1
    d 0
  end
end
