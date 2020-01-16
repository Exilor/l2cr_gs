class Packets::Outgoing::PetStatusShow < GameServerPacket
  @type : Int32

  def initialize(summon : L2Summon)
    @type = summon.summon_type
  end

  private def write_impl
    c 0xb1
    d @type
  end
end
