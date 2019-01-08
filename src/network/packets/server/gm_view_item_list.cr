class Packets::Outgoing::GMViewItemList < Packets::Outgoing::AbstractItemPacket
  @player_name : String
  @limit : Int32
  @items : Slice(L2ItemInstance)

  def initialize(char : L2PcInstance | L2PetInstance)
    @player_name = char.name
    @limit = char.inventory_limit
    @items = char.inventory.items.to_slice
  end

  def write_impl
    c 0x9a

    s @player_name
    d @limit
    h 0x01
    h @items.size
    @items.each { |item| write_item(item) }
  end
end
