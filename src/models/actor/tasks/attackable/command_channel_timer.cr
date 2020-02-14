struct CommandChannelTimer
  initializer mob : L2Attackable

  def call
    if Time.ms - @mob.command_channel_last_attack > Config.loot_raids_privilege_interval
      @mob.command_channel_timer = nil
      @mob.first_command_channel_attacked = nil
      @mob.command_channel_last_attack = 0
    else
      ThreadPoolManager.schedule_general(self, 10000)
    end
  end
end
