require "../../actor/tasks/player/teleport_task"

class L2JailZone < L2ZoneType
  private JAIL_IN_LOC  = Location.new(-114356, -249645, -2984)
	private JAIL_OUT_LOC = Location.new(17836, 170178, -3507)

  def on_enter(char)
    if char.player?
      char.inside_jail_zone = true
      char.inside_no_summon_friend_zone = true

      if Config.jail_is_pvp
        char.inside_pvp_zone = true
        char.send_packet(SystemMessageId::ENTERED_COMBAT_ZONE)
      end

      if Config.jail_disable_transaction
        char.inside_no_store_zone = true
      end
    end
  end

  def on_exit(char)
    if char.is_a?(L2PcInstance)
      char.inside_jail_zone = false
      char.inside_no_summon_friend_zone = false

      if Config.jail_is_pvp
        char.inside_pvp_zone = false
        char.send_packet(SystemMessageId::LEFT_COMBAT_ZONE)
      end

      if char.jailed?
        task = TeleportTask.new(char, JAIL_IN_LOC)
        ThreadPoolManager.schedule_general(task, 2000)
        char.send_message("You cannot cheat your way out of here. You must wait until your jail time is over.")
      end

      if Config.jail_disable_transaction
        char.inside_no_store_zone = false
      end
    end
  end

  def self.location_in : Location
    JAIL_IN_LOC
  end

  def self.location_out : Location
    JAIL_OUT_LOC
  end
end
