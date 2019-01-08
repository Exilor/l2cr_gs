class PlayerEventHolder
  getter kills
  property? sit_forced

  @name : String
  @title : String
  @clan_id : Int32
  @pvp_kills : Int32
  @pk_kills : Int32
  @karma : Int32

  def initialize(@pc : L2PcInstance, @sit_forced : Bool = false)
    @name = pc.name
    @title = pc.title
    @clan_id = pc.clan_id
    @loc = Location.new(pc)
    @pvp_kills = pc.pvp_kills
    @pk_kills = pc.pk_kills
    @karma = pc.karma
  end

  def restore_player_stats
    @pc.name = @name
    @pc.title = @title
    @pc.clan = ClanTable.get_clan(@clan_id)
    @pc.tele_to_location(@loc, true)
    @pc.pvp_kills = @pvp_kills
    @pc.pk_kills = @pk_kills
    @pc.karma = @karma
  end
end
