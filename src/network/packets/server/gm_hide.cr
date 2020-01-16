class Packets::Outgoing::GMHide < GameServerPacket
  initializer mode : Int32

  private def write_impl
    c 0x93
    d @mode
  end
end
