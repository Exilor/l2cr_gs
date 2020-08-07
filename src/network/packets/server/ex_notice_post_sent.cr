class Packets::Outgoing::ExNoticePostSent < GameServerPacket
  private initializer show_animation : Bool

  private def write_impl
    c 0xfe
    h 0xb4

    d @show_animation ? 1 : 0
  end

  TRUE  = new(true)
  FALSE = new(false)
end
