class Packets::Outgoing::ExShowFortressInfo < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x15

    forts = FortManager.forts
    d forts.size
    forts.each do |fort|
      clan = fort.owner_clan?
      d fort.residence_id
      s clan ? clan.name : ""
      d fort.siege.in_progress? ? 1 : 0
      d fort.owned_time
    end
  end
end
