class Packets::Outgoing::PledgeReceiveWarList < GameServerPacket
  initializer clan : L2Clan, tab : Int32

  private def write_impl
    c 0xfe
    h 0x3f

    d @tab # 0: declared, 1: under attack
    d 0 # page
    list = @tab == 0 ? @clan.war_list : @clan.attacker_list
    d list.size
    list.each do |i|
      unless clan = ClanTable.get_clan(i)
        next
      end

      s clan.name
      d @tab
      d @tab
    end
  end
end
