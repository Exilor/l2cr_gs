class Packets::Outgoing::ExPledgeCrestLarge < GameServerPacket
  @data : Bytes?

  initializer crest_id: Int32, data: Bytes

  def initialize(@crest_id : Int32)
    @data = CrestTable.get_crest(crest_id).try &.data
  end

  def write_impl
    c 0xfe
    h 0x1b

    d 0
    d @crest_id
    if data = @data
      d data.size
      b data
    else
      d 0
    end
  end
end
