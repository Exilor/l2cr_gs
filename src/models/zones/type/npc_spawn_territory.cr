class NpcSpawnTerritory
  @id = 0

  initializer name: String, territory: L2ZoneForm

  def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
    @territory.inside_zone?(x, y, z)
  end

  def random_point
    @territory.random_point
  end
end

