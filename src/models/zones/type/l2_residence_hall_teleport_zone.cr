require "./l2_residence_teleport_zone"

class L2ResidenceHallTeleportZone < L2ResidenceTeleportZone
  @tele_task : Scheduler::DelayedTask?

  def set_parameter(name, value)
    if name == "residenceZoneId"
      @id = value.to_i
    else
      super
    end
  end

  def residence_zone_id
    @id
  end

  def check_teleport_task
    task = @tele_task
    if task.nil? || task.done?
      tmp = TeleportTask.new(self)
      @tele_task = ThreadPoolManager.schedule_general(tmp, 30_000)
    end
  end

  private struct TeleportTask
    initializer zone : L2ResidenceHallTeleportZone

    def call
      loc = @zone.spawns.not_nil!.sample(random: Rnd)
      @zone.players_inside.each &.tele_to_location(loc, false)
    end
  end
end
