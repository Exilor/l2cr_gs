class Packets::Outgoing::ExReplyDominionInfo < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x92

    territory_list = TerritoryWarManager.territories
    d territory_list.size
    territory_list.each do |t|
      d t.territory_id
      s CastleManager.get_castle_by_id(t.castle_id).not_nil!.name.downcase + "_dominion"
      s t.owner_clan.name
      d t.owned_ward_ids.size
      t.owned_ward_ids.each { |i| d i }
      d TerritoryWarManager.tw_start_time_in_millis // 1000
    end
  end
end
