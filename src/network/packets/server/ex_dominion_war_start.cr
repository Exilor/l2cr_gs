class Packets::Outgoing::ExDominionWarStart < GameServerPacket
  @l2id : Int32

  def initialize(pc : L2PcInstance)
    @l2id = pc.l2id
    @territory_id = TerritoryWarManager.get_registered_territory_id(pc)
    @disguised = TerritoryWarManager.disguised?(@l2id)
  end

  private def write_impl
    c 0xfe
    h 0xa3

    d @l2id
    d 0x01
    d @territory_id
    d @disguised ? 1 : 0
    d @disguised ? @territory_id : 0
  end
end
