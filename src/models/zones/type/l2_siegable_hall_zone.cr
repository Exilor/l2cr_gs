class L2SiegableHallZone < L2ClanHallZone
  getter challenger_spawns = [] of Location

  def parse_loc(x : Int32, y : Int32, z : Int32, type : String?)
    if type == "challenger"
      @challenger_spawns << Location.new(x, y, z)
    else
      super
    end
  end

  def banish_non_siege_participants
    each_player_inside do |pc|
      if pc.in_hideout_siege?
        pc.tele_to_location(banish_spawn_loc, true)
      end
    end
  end
end
