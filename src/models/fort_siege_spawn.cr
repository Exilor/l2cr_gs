class FortSiegeSpawn < Location
  getter id, fort_id, message_id

  def initialize(fort_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32, id : Int32, message_id : Int32)
    super(x, y, z, heading)

    @fort_id = fort_id
    @id = id
    @message_id = message_id
  end
end
