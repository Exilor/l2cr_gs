struct L2ExtractableProduct
  getter id, min, max, chance : Int32

  def initialize(id : Int32, min : Int32, max : Int32, chance : Float64)
    @id = id
    @min = min
    @max = max
    @chance = (chance * 1000).to_i32
  end
end
