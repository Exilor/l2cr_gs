class Packets::Outgoing::ExShowSeedMapInfo < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0xa1

    d 2

    d -246857
    d 251960
    d 4331
    d 2770 + GraciaSeedsManager.sod_state

    d -213770
    d 210760
    d 4400

    d 2766
  end
end
