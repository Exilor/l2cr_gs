class Packets::Outgoing::ExConfirmAddingContact < GameServerPacket
  initializer char_name : String, added : Bool

  def write_impl
    c 0xfe
    h 0xd2

    s @char_name
    d @added ? 1 : 0
  end
end
