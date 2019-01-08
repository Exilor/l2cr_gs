module NullRegion
  extend self
  extend IRegion

  def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    true
  end

  def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
    z
  end

  def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
    z
  end

  def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
    z
  end

  def has_geo? : Bool
    false
  end
end
