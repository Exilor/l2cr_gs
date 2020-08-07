abstract class Packets::Outgoing::AbstractNpcInfo < GameServerPacket
  @collision_height = 0.0
  @collision_radius = 0.0
  @r_hand = 0
  @l_hand = 0
  @chest = 0
  @enchant_effect = 0
  @attackable = false
  @summoned = false
  @name = ""
  @title : String? = ""
  @id_template = 0
  @x : Int32
  @y : Int32
  @z : Int32
  @m_atk_spd : Int32
  @p_atk_spd : Int32
  @heading : Int32
  @move_multiplier : Float64
  @run_spd : Int32
  @walk_spd : Int32
  @swim_run_spd : Int32
  @swim_walk_spd : Int32
  @fly_run_spd : Int32
  @fly_walk_spd : Int32

  def initialize(char : L2Character)
    @summoned = char.show_summon_animation?
    @x, @y, @z = char.xyz
    @heading = char.heading
    @m_atk_spd = char.m_atk_spd
    @p_atk_spd = char.p_atk_spd.to_i
    @move_multiplier = char.movement_speed_multiplier
    @run_spd = (char.run_speed / @move_multiplier).to_i
    @walk_spd = (char.walk_speed / @move_multiplier).to_i
    @swim_run_spd = (char.swim_run_speed / @move_multiplier).to_i
    @swim_walk_spd = (char.swim_walk_speed / @move_multiplier).to_i
    @fly_run_spd = char.flying? ? @run_spd : 0
    @fly_walk_spd = char.flying? ? @walk_spd : 0
  end
end
