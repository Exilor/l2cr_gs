class Packets::Outgoing::OnEventTrigger < GameServerPacket
  @emitter_id : Int32

  def initialize(door : L2DoorInstance, is_enabled : Bool)
    @emitter_id = door.emitter
    @enabled = is_enabled ? 1 : 0
  end

  private def write_impl
    c 0xcf

    d @emitter_id
    c @enabled
  end
end
