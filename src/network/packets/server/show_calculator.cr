class Packets::Outgoing::ShowCalculator < GameServerPacket
  initializer calculator_id : Int32

  private def write_impl
    c 0xe2
    d @calculator_id
  end
end
