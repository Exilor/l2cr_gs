class Packets::Outgoing::ExDuelAskStart < GameServerPacket
  initializer requestor_name : String, party_duel : Bool

  def write_impl
    c 0xfe
    h 0x4c

    s @requestor_name
    d @party_duel ? 1 : 0
  end
end
