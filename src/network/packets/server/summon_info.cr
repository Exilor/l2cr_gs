class Packets::Outgoing::SummonInfo < Packets::Outgoing::AbstractNpcInfo
  @form : Int32

  def initialize(char : L2Summon, attacker : L2Character, @val : Int32)
    super(char)

    @summon = char
    @form = char.form_id

    @attackable = char.auto_attackable?(attacker)
    @collision_height = char.template.collision_height.to_f
    @collision_radius = char.template.collision_radius.to_f
    @r_hand = char.weapon
    @l_hand = 0
    @chest = char.armor
    @enchant_effect = char.template.weapon_enchant
    @name = char.name || "Missing name!"
    @title = (char.owner.online? ? char.owner.name : "") || "Missing title!"
    @id_template = char.template.display_id
    self.invisible = char.invisible?
  end

  private def write_impl
    gm_see_invis = false

    if invisible?
      active_char = client.active_char
      if active_char && active_char.override_see_all_players?
        gm_see_invis = true
      end
    end

    sum = @summon

    c 0x0c

    d sum.l2id
    d @id_template + 1_000_000
    d @attackable ? 1 : 0
    d @x
    d @y
    d @z
    d @heading
    d 0x00
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
    f sum.attack_speed_multiplier
    f @collision_radius
    f @collision_height

    d @r_hand
    d @chest
    d @l_hand

    c 0x01 # name above char
    c 0x01 # running? ? 1 : 0
    c sum.in_combat? ? 1 : 0
    c sum.looks_dead? ? 1 : 0
    c @val # invisible ?? 0=false 1=true 2=summoned (only works if model has a summon animation)

    d -1
    s @name
    d -1
    s @title

    d 0x01
    d sum.pvp_flag
    d sum.karma
    if gm_see_invis
      d sum.abnormal_visual_effects | AbnormalVisualEffect::STEALTH.mask
    else
      d sum.abnormal_visual_effects
    end
    d 0
    d 0
    d 0
    d 0

    c sum.inside_water_zone? ? 1 : sum.flying? ? 2 : 0
    c sum.team.to_i

    f @collision_radius
    f @collision_height

    d @enchant_effect
    d 0x00
    d 0x00
    d @form
    c 0x01
    c 0x01
    d sum.abnormal_visual_effects_special
  end
end
