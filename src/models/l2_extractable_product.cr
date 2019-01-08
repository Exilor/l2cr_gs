struct L2ExtractableProduct
  getter id, min, max
  getter chance : Int32

  def initialize(@id : Int32, @min : Int32, @max : Int32, chance : Float64)
    @chance = (chance * 1000).to_i32
  end
end
