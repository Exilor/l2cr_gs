class Packets::Outgoing::TargetSelected < GameServerPacket
  initializer char_id: Int32, target_id: Int32, x: Int32, y: Int32, z: Int32

  def write_impl
    c 0x23

    d @char_id
    d @target_id
    d @x
    d @y
    d @z
    d 0x00 # ??
  end
end
