class Packets::Outgoing::MoveToPawn < GameServerPacket
  @char_id : Int32
  @target_id : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @target_x : Int32
  @target_y : Int32
  @target_z : Int32

  def initialize(char : L2Character, target : L2Character, @distance : Int32)
    @char_id = char.l2id
    @target_id = target.l2id
    @x, @y, @z = char.xyz
    @target_x = target.x
    @target_y = target.y
    @target_z = target.z
  end

  private def write_impl
    c 0x72

    d @char_id
    d @target_id
    d @distance
    d @x
    d @y
    d @z
    d @target_x
    d @target_y
    d @target_z
  end
end
