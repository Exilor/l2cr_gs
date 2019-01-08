class Packets::Outgoing::ExNoticePostSent < GameServerPacket
  protected setter show_animation

  initializer show_animation: Bool

  def self.new(value : Bool) : ExNoticePostArrived
    value ? TRUE : FALSE
  end

  def write_impl
    c 0xfe
    h 0xb4

    d @show_animation ? 1 : 0
  end

  TRUE = allocate
  TRUE.show_animation = true

  FALSE = allocate
  FALSE.show_animation = false
end
