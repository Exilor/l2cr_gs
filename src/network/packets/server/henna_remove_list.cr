class Packets::Outgoing::HennaRemoveList < GameServerPacket
  initializer pc : L2PcInstance

  private def write_impl
    c 0xe6

    q @pc.adena
    d 0x00
    d 3 &- @pc.henna_empty_slots

    @pc.henna_list.each do |henna|
      if henna
        d henna.dye_id
        d henna.dye_item_id
        d henna.cancel_count
        d 0x00
        d henna.cancel_fee
        d 0x00
        d 0x01
      end
    end
  end
end
