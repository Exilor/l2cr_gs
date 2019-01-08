require "./l2_residence_zone"

class L2CastleZone < L2ResidenceZone
  def set_parameter(name, value)
    if name == "castleId"
      self.residence_id = value.to_i
    else
      super
    end
  end

  def on_enter(char)
    char.inside_castle_zone = true
  end

  def on_exit(char)
    char.inside_castle_zone = false
  end
end
