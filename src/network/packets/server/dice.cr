class Packets::Outgoing::Dice < GameServerPacket
  initializer char_id : Int32, item_id : Int32, number : Int32, x : Int32,
    y : Int32, z : Int32

  private def write_impl
    c 0xda

    d @char_id
    d @item_id
    d @number
    d @x
    d @y
    d @z
  end
end
