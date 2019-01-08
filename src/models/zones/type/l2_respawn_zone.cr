class L2RespawnZone < L2ZoneType
  @race_respawn_point = EnumMap(Race, String).new

  def on_enter(char)
    # no-op
  end

  def on_exit(char)
    # no-op
  end

  def add_race_respawn_point(race : String, point : String) # String, String
    @race_respawn_point[Race.parse(race)] = point
  end

  def get_respawn_point(pc : L2PcInstance)
    @race_respawn_point[pc.race]
  end

  def all_respawn_points
    @race_respawn_point
  end
end
