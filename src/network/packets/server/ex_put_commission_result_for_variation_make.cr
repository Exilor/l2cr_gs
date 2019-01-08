class Packets::Outgoing::ExPutCommissionResultForVariationMake < GameServerPacket
  def initialize(@gem : Int32, @count : Int64, @id : Int32)
    @unk1 = 0
    @unk2 = 0
    @unk3 = 1
  end

  def write_impl
    c 0xfe
    h 0x55

    d @gem
    d @id
    q @count
    d @unk1
    d @unk2
    d @unk3
  end
end
