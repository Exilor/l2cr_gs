class InstanceWorld
  getter allowed = [] of Int32
  property instance_id : Int32 = 0
  property template_id : Int32 = -1
  @status = Atomic(Int32).new(0)

  def remove_allowed(id : Int32)
    @allowed.delete_first(id)
  end

  def add_allowed(id : Int32)
    @allowed << id
  end

  def allowed?(id : Int32) : Bool
    @allowed.includes?(id)
  end

  def status : Int32
    @status.get
  end

  def status?(status : Int) : Bool
    @status.get == status
  end

  def status=(val : Int32)
    @status.set(val)
  end

  def inc_status
    @status.add(1)
  end

  def on_death(killer : L2Character?, victim : L2Character?) # killer is unused
    return unless victim && victim.player?
    return unless instance = InstanceManager.get_instance(@instance_id)
    pc = victim.acting_player
    sm = Packets::Outgoing::SystemMessage.you_will_be_expelled_in_s1
    sm.add_int(instance.eject_time / 60 / 1000)
    pc.send_packet(sm)
    instance.add_eject_dead_task(pc)
  end
end
