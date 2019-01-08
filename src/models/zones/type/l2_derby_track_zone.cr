class L2DerbyTrackZone < L2ZoneType
  def on_enter(char)
    if char.playable?
      char.inside_monster_track_zone = true
    end
  end

  def on_exit(char)
    if char.playable?
      char.inside_monster_track_zone = false
    end
  end
end
