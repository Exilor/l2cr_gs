class Packets::Outgoing::ExShowOwnthingPos < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x93

    if TerritoryWarManager.tw_in_progress?
      list = TerritoryWarManager.territory_wards
      d list.size
      list.each do |ward|
        d ward.territory_id

        if npc = ward.npc?
          l npc
        elsif pc = ward.player?
          l pc
        else
          d 0
          d 0
          d 0
        end
      end
    else
      d 0
    end
  end
end
