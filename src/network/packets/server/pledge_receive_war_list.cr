class Packets::Outgoing::PledgeReceiveWarList < GameServerPacket
  initializer clan: L2Clan, tab: Int32

  def write_impl
    c 0xfe
    h 0x3f

    d @tab
    d 0
    list = @tab == 0 ? @clan.war_list : @clan.attacker_list
    d list.size
    list.each do |i|
      unless clan = ClanTable.get_clan(i)
        warn "Clan with ID #{i} not found."
        next
      end

      s clan.name
      d @tab
      d @tab
    end
  end
end
