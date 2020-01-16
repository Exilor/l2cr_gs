class Packets::Outgoing::HennaEquipList < GameServerPacket
  def initialize(@pc : L2PcInstance)
    @henna_equip_list = HennaData.get_henna_list(pc.class_id)
  end

  private def write_impl
    c 0xee

    q @pc.adena
    d 3 # available slots
    d @henna_equip_list.size

    @henna_equip_list.each do |henna|
      if @pc.inventory.get_item_by_item_id(henna.dye_item_id)
        d henna.dye_id
        d henna.dye_item_id
        q henna.wear_count
        q henna.wear_fee
        d henna.allowed_class?(@pc.class_id) ? 1 : 0
      end
    end
  end
end
