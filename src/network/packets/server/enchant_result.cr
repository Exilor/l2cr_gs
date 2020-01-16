class Packets::Outgoing::EnchantResult < GameServerPacket
  initializer result : Int32, crystal : Int32, count : Int32

  private def write_impl
    c 0x87

    d @result
    d @crystal
    q @count
  end

  SUCCESS = new(0, 0, 0)
  ERROR   = new(2, 0, 0)
  BLESSED_FAILURE = new(3, 0, 0)
  NO_CRYSTAL_FAILURE = new(4, 0, 0)
  FAILURE = new(5, 0, 0)
end
