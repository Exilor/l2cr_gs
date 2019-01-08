class Packets::Outgoing::ExShowAgitInfo < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x16

    halls = ClanHallManager.auctionable_clan_halls
    d halls.size
    halls.each_value do |ch|
      d ch.id
      s ch.owner_id <= 0 ? "" : ClanTable.get_clan!(ch.owner_id).name
      s ch.owner_id <= 0 ? "" : ClanTable.get_clan!(ch.owner_id).leader_name
      d ch.grade > 0 ? 0 : 1 # 0 - auction 1 - war clanhall 2 - ETC (rainbow spring clanhall)
    end
  end
end
