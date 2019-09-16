struct CommandChannelTimer
  initializer attackable: L2Attackable

  def call
    if Time.ms - @attackable.command_channel_last_attack > Config.loot_raids_privilege_interval
      @attackable.command_channel_timer = nil
      @attackable.first_command_channel_attacked = nil
      @attackable.command_channel_last_attack = 0
    else
      ThreadPoolManager.schedule_general(self, 10000)
    end
  end
end
