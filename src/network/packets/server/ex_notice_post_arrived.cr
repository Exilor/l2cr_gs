class Packets::Outgoing::ExNoticePostArrived < GameServerPacket
  protected setter show_animation

  initializer show_animation : Bool

  def self.new(value : Bool) : self
    value ? TRUE : FALSE
  end

  private def write_impl
    c 0xfe
    h 0xa9

    d @show_animation ? 1 : 0
  end

  TRUE = allocate
  TRUE.show_animation = true

  FALSE = allocate
  FALSE.show_animation = false
end
