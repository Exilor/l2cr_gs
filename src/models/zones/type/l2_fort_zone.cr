class L2FortZone < L2ResidenceZone
  def set_parameter(name : String, value : String)
    if name == "fortId"
      self.residence_id = value.to_i
    else
      super
    end
  end

  def on_enter(char)
    char.inside_fort_zone = true
  end

  def on_exit(char)
    char.inside_fort_zone = false
  end
end
