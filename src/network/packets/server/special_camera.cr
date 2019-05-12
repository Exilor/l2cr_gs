class Packets::Outgoing::SpecialCamera < GameServerPacket
  @id : Int32

  def initialize(char : L2Character, force : Int32, angle1 : Int32, angle2 : Int32, time : Int32, range : Int32, duration : Int32, rel_yaw : Int32, rel_pitch : Int32, is_wide : Int32, rel_angle : Int32)
    initialize(char, force, angle1, time, duration, range, rel_yaw, rel_pitch, is_wide, rel_angle, 0)
  end

  def initialize(char : L2Character, talker : L2Character, force : Int32, angle1 : Int32, angle2 : Int32, time : Int32, duration : Int32, rel_yaw : Int32, rel_pitch : Int32, is_wide : Int32, rel_angle : Int32)
    initialize(char, force, angle1, angle2, time, duration, 0, rel_yaw, rel_pitch, is_wide, rel_angle, 0)
  end

  def initialize(char : L2Character, @force : Int32, @angle1 : Int32, @angle2 : Int32, @time : Int32, range : Int32, @duration : Int32, @rel_yaw : Int32, @rel_pitch : Int32, @is_wide : Int32, @rel_angle : Int32, @unk : Int32)
    @id = char.l2id
  end

  def write_impl
    c 0xd6

    d @id
    d @force
    d @angle1
    d @angle2
    d @time
    d @duration
    d @rel_yaw
    d @rel_pitch
    d @is_wide
    d @rel_angle
    d @unk
  end
end
