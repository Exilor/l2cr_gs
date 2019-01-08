struct ClanInfo
  getter clan, total : Int32, online : Int32

  def initialize(@clan : L2Clan)
    @total = clan.members_count
    @online = clan.online_members_count
  end
end
