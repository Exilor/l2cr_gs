class Packets::Outgoing::HennaItemRemoveInfo < GameServerPacket
  initializer henna : L2Henna, pc : L2PcInstance

  private def write_impl
    c 0xe7

    d @henna.dye_id
    d @henna.dye_item_id
    q @henna.wear_count
    q @henna.wear_fee
    d @henna.allowed_class?(@pc.class_id) ? 0x01 : 0x00
    q @pc.adena
    d @pc.int
    c @pc.int &- @henna.int
    d @pc.str
    c @pc.str &- @henna.str
    d @pc.con
    c @pc.con &- @henna.con
    d @pc.men
    c @pc.men &- @henna.men
    d @pc.dex
    c @pc.dex &- @henna.dex
    d @pc.wit
    c @pc.wit &- @henna.wit
  end
end
