class L2HqZone < L2ZoneType
  def set_parameter(name, value)
    case name
    when "castleId"
      # L2J TODO
    when "fortId"
      # L2J TODO
    when "clanHallId"
      # L2J TODO
    when "territoryId"
      # L2J TODO
    else
      super
    end
  end

  def on_enter(char)
    if char.player?
      char.inside_hq_zone = true
    end
  end

  def on_exit(char)
    if char.player?
      char.inside_hq_zone = false
    end
  end
end
