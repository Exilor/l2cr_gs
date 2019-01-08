class Packets::Outgoing::ExShowDominionRegistry < GameServerPacket
  private MINID = 80

  def initialize(@castle_id : Int32, pc : L2PcInstance)
    if clans = TerritoryWarManager.get_registered_clans(castle_id)
      @clan_req = clans.size
      if clan = pc.clan?
        @clan_registered = clans.includes?(clan) ? 1 : 0
      end
    end

    if mercs = TerritoryWarManager.get_registered_mercenaries(castle_id)
      @merc_req = mercs.size
      @merc_registered = mercs.includes?(pc.l2id) ? 1 : 0
    end

    @war_time = Time.s
  end

  def write_impl
    c 0xfe
    h 0x90

    d MINID + @castle_id
  end
end
