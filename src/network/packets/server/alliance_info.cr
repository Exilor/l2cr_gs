require "../../../models/clan_info"

class Packets::Outgoing::AllianceInfo < GameServerPacket
  getter name : String
  getter leader_c : String
  getter leader_p : String
  getter total : Int32
  getter online : Int32
  getter allies = [] of ClanInfo

  def initialize(alliance_id : Int32)
    leader_clan = ClanTable.get_clan(alliance_id).not_nil!
    @name = leader_clan.ally_name || ""
    @leader_c = leader_clan.name
    @leader_p = leader_clan.leader_name

    total = online = 0
    ClanTable.get_clan_allies(alliance_id) do |clan|
      ci = ClanInfo.new(clan)
      total += ci.total
      online += ci.online
      @allies << ci
    end
    @total = total
    @online = online
  end

  private def write_impl
    c 0xb5

    s @name
    d @total
    d @online
    s @leader_c
    s @leader_p

    d @allies.size
    @allies.each do |aci|
      s aci.clan.name
      d 0
      d aci.clan.level
      s aci.clan.leader_name
      d aci.total
      d aci.online
    end
  end
end
