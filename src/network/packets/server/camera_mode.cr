class Packets::Outgoing::CameraMode < GameServerPacket
  initializer mode : Bool

  def write_impl
    c 0xf7
    d @mode ? 1 : 0
  end

  THIRD_PERSON = new(false)
  FIRST_PERSON = new(true)
end
