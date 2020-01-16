class Packets::Outgoing::ExDuelEnd < GameServerPacket
  private initializer party_duel : Bool

  private def write_impl
    c 0xfe
    h 0x4f

    d @party_duel ? 1 : 0
  end

  PLAYER_DUEL = new(false)
  PARTY_DUEL  = new(true)
end
