class Packets::Outgoing::ShortBuffStatusUpdate < GameServerPacket
  initializer skill_id : Int32, skill_lvl : Int32, duration : Int32

  def write_impl
    c 0xfa

    d @skill_id
    d @skill_lvl
    d @duration
  end

  STATIC_PACKET = new(0, 0, 0)
end
