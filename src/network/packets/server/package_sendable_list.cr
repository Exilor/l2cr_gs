class Packets::Outgoing::PackageSendableList < Packets::Outgoing::AbstractItemPacket
  initializer items : Array(L2ItemInstance), pc_id : Int32

  private def write_impl
    c 0xd2

    d @pc_id
    q client.active_char.not_nil!.adena
    d @items.size
    @items.each do |item|
      write_item(item)
      d item.l2id
    end
  end
end
