class L2FishingZone < L2ZoneType
  def on_enter(char)
    # no-op
  end

  def on_exit(char)
    # no-op
  end

  def water_z : Int32
    zone.high_z
  end
end
