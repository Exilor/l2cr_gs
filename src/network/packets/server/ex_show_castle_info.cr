class Packets::Outgoing::ExShowCastleInfo < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x14

    castles = CastleManager.castles

    d castles.size
    castles.each do |castle|
      d castle.residence_id

      if castle.owner_id > 0
        if clan = ClanTable.get_clan(castle.owner_id)
          s clan.name
        else
          warn "Castle with owner_id > 0 (#{castle.owner_id}) but without clan."
          s ""
        end
      else
        s ""
      end

      d castle.tax_percent
      d castle.siege.siege_date.ms / 1000
    end
  end
end
