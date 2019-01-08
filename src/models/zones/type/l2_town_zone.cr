class L2TownZone < L2ZoneType
  getter town_id = 0
  getter tax_by_id = 0

  def set_parameter(name, value)
    case name
    when "townId"
      @town_id = value.to_i
    when "taxById"
      @tax_by_id = value.to_i
    else
      super
    end
  end

  def on_enter(char)
    char.inside_town_zone = true
  end

  def on_exit(char)
    char.inside_town_zone = false
  end
end
