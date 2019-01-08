class Packets::Outgoing::ExVariationCancelResult < GameServerPacket
  private initializer result: Int32

  def write_impl
    c 0xfe
    h 0x58

    d @result
  end

  FAIL = new(0)
  SUCCESS = new(1)
end
