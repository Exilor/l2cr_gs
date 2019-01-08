class Packets::Outgoing::ExGetPremiumItemList < GameServerPacket
  initializer pc: L2PcInstance

  def write_impl
    c 0xfe
    h 0x86

    d @pc.premium_item_list.size
    @pc.premium_item_list.each do |k, v|
      d k
      d @pc.l2id
      d v.item_id
      q v.count
      d 0
      s v.sender
    end
  end
end
