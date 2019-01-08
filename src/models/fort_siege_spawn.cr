class FortSiegeSpawn < Location
  # include Identifiable

  getter fort_id

  def initialize(@fort_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32, @npc_id : Int32, @id : Int32)
    super(x, y, z, heading)
  end

  def id : Int32
    @npc_id
  end

  def message_id : Int32
    @id
  end
end
