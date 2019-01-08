class L2LandingZone < L2ZoneType
  def on_enter(char)
    if char.player?
      char.inside_landing_zone = true
    end
  end

  def on_exit(char)
    if char.player?
      char.inside_landing_zone = false
    end
  end
end
