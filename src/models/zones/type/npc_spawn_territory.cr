struct NpcSpawnTerritory
  getter name

  initializer name : String, territory : L2ZoneForm

  def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
    @territory.inside_zone?(x, y, z)
  end

  def random_point : {Int32, Int32, Int32}
    @territory.random_point
  end

  def visualize_zone(z : Int32)
    @territory.visualize_zone(z)
  end
end
