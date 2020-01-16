class Packets::Outgoing::FlyToLocation < GameServerPacket
  @l2id : Int32
  @char_x : Int32
  @char_y : Int32
  @char_z : Int32

  def initialize(char : L2Character, @dest_x : Int32, @dest_y : Int32, @dest_z : Int32, @fly_type : FlyType)
    @l2id = char.l2id
    @char_x, @char_y, @char_z = char.xyz
  end

  def initialize(char : L2Character, dst : Locatable, fly_type : FlyType)
    initialize(char, *dst.xyz, fly_type)
  end

  private def write_impl
    c 0xd4

    d @l2id
    d @dest_x
    d @dest_y
    d @dest_z
    d @char_x
    d @char_y
    d @char_z
    d @fly_type.to_i
  end
end
