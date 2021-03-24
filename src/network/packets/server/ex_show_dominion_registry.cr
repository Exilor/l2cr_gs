class Packets::Outgoing::ExShowDominionRegistry < GameServerPacket
  private MINID = 80

  @clan_req = 0
  @merc_req = 0
  @clan_registered = 0
  @merc_registered = 0
  @current_time : Int32 = Time.s.to_i32

  def initialize(castle_id : Int32, pc : L2PcInstance)
    @castle_id = castle_id
    if clans = TerritoryWarManager.get_registered_clans(castle_id)
      @clan_req = clans.size
      if clan = pc.clan
        @clan_registered = clans.includes?(clan) ? 1 : 0
      end
    end

    if mercs = TerritoryWarManager.get_registered_mercenaries(castle_id)
      @merc_req = mercs.size
      @merc_registered = mercs.includes?(pc.l2id) ? 1 : 0
    end

    @war_time = Time.s
  end

  private def write_impl
    c 0xfe
    h 0x90

    d MINID &+ @castle_id
    territory = TerritoryWarManager.get_territory(@castle_id)

    if territory.nil?
      s "No Owner"
      s "No Owner"
      s "No Ally"
    else
      if clan = territory.owner_clan?
        s clan.name
        s clan.leader_name
        s clan.ally_name
      else
        s "No Owner"
        s "No Owner"
        s "No Ally"
      end

      d @clan_req
      d @merc_req
      d @war_time
      d @current_time
      d @clan_registered
      d @merc_registered
      d 0x01 # unknown
      territory_list = TerritoryWarManager.territories
      d territory_list.size
      territory_list.each do |t|
        d t.territory_id
        d t.owned_ward_ids.size
        t.owned_ward_ids.each { |i| d i }
      end
    end
  end
end
