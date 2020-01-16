class Packets::Outgoing::SpawnItem < GameServerPacket
  @l2id : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @item_id : Int32
  @stackable : Bool

  def initialize(obj : L2Object)
      @l2id = obj.l2id
      @x, @y, @z = obj.xyz

      if obj.is_a?(L2ItemInstance)
        @item_id = obj.display_id
        @stackable = obj.stackable?
        @count = obj.count
      else
        @item_id = obj.poly.poly_id
        @stackable = false
        @count = 1i64
      end
    end

  private def write_impl
    c 0x05

    d @l2id
    d @item_id
    d @x
    d @y
    d @z
    d @stackable ? 1 : 0
    q @count
    # d 0x00
    # d 0x00
    q 0
  end
end
