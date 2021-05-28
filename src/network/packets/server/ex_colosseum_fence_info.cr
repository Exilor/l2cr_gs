class Packets::Outgoing::ExColosseumFenceInfo < GameServerPacket
  initializer fence : L2ColosseumFence

  private def write_impl
    c 0xfe
    h 0x0003

    d @fence.l2id
    d @fence.fence_state.to_i
    l @fence
    d @fence.fence_width
    d @fence.fence_height
  end
end
