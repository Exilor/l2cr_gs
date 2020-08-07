class Packets::Outgoing::ExUseSharedGroupItem < GameServerPacket
  @remaining_time : Int32
  @total_time : Int32

  def initialize(item_id : Int32, group_id : Int32, remaining_time : Int32, total_time : Int32)
    @item_id = item_id
    @group_id = group_id
    @remaining_time = remaining_time // 1000
    @total_time = total_time // 1000
  end

  private def write_impl
    c 0xfe
    h 0x4a

    d @item_id
    d @group_id
    d @remaining_time
    d @total_time
  end
end
