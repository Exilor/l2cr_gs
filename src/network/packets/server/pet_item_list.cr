class Packets::Outgoing::PetItemList < Packets::Outgoing::AbstractItemPacket
  initializer items : IArray(L2ItemInstance)

  def write_impl
    c 0xb3

    h @items.size
    @items.each { |item| write_item(item) }
  end
end
