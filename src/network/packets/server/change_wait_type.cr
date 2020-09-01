class Packets::Outgoing::ChangeWaitType < GameServerPacket
  SITTING = 0u8
  STANDING = 1u8
  START_FAKE_DEATH = 2u8
  STOP_FAKE_DEATH = 3u8

  @id : Int32
  @x : Int32
  @y : Int32
  @z : Int32

  def initialize(char : L2Character, type : UInt8)
    @type = type
    @id = char.l2id
    @x, @y, @z = char.xyz
  end

  private def write_impl
    c 0x29

    d @id
    d @type
    d @x
    d @y
    d @z
  end
end
