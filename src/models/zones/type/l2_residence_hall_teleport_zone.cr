require "./l2_residence_teleport_zone"

class L2ResidenceHallTeleportZone < L2ResidenceTeleportZone
  # def initialize(id)
  #   super

  #   @tele_task = nil # Runnable
  # end

  @tele_task : Runnable::DelayedTask?

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

  struct TeleportTask
    include Runnable

    initializer zone: L2ResidenceHallTeleportZone

    def run
      index = 0
      loc = @zone.spawns.not_nil!.sample
      @zone.players_inside { |pc| pc.tele_to_location(loc, false) }
    end
  end
end
