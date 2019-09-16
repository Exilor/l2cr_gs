class L2OlympiadStadiumZone < L2ZoneRespawn
  getter spectator_spawns = [] of Location

  def initialize(id)
    super(id)
    self.settings = ZoneManager.get_settings(name) || Settings.new
  end

  def register_task(task)
    settings.task = task
  end

  def open_doors
    InstanceManager.get_instance!(instance_id).doors.each do |door|
      if door.closed?
        door.open_me
      end
    end
  end

  def close_doors
    InstanceManager.get_instance!(instance_id).doors.each do |door|
      if door.open?
        door.close_me
      end
    end
  end

  def spawn_buffers
    InstanceManager.get_instance!(instance_id).npcs.each do |buffer|
      if buffer.is_a?(L2OlympiadManagerInstance) && !buffer.visible?
        buffer.spawn_me
      end
    end
  end

  def delete_buffers
    InstanceManager.get_instance!(instance_id).npcs.each do |buffer|
      if buffer.is_a?(L2OlympiadManagerInstance) && buffer.visible?
        buffer.decay_me
      end
    end
  end

  def broadcast_status_update(pc)
    packet = ExOlympiadUserInfo.new(pc)
    players_inside do |target|
      if target.in_observer_mode? || target.olympiad_side != pc.olympiad_side
        target.send_packet(packet)
      end
    end
  end

  def broadcast_packet_to_observers(gsp)
    players_inside do |pc|
      if pc.in_observer_mode?
        pc.send_packet(gsp)
      end
    end
  end

  def on_enter(char)
    if settings.olympiad_task?.try &.battle_started?
      char.inside_pvp_zone = true
      if char.player?
        char.send_packet(SystemMessageId::ENTERED_COMBAT_ZONE)
        settings.olympiad_task.game.send_olympiad_info(char)
      end
    end

    if char.playable?
      if pc = char.acting_player
        if !pc.override_zone_conditions? && !pc.in_olympiad_mode? && !pc.in_observer_mode?
          ThreadPoolManager.execute_general(KickPlayer.new(pc))
        else
          if pc.has_pet?
            pc.summon!.unsummon(pc)
          end
        end
      end
    end
  end

  def on_exit(char)
    if settings.olympiad_task?.try &.battle_started?
      char.inside_pvp_zone = false
      if char.player?
        char.send_packet(SystemMessageId::LEFT_COMBAT_ZONE)
        char.send_packet(ExOlympiadMatchEnd::STATIC_PACKET)
      end
    end
  end

  def update_zone_status_for_characters_inside
    return unless task = settings.olympiad_task

    battle_started = task.battle_started?

    if battle_started
      sm = SystemMessageId::ENTERED_COMBAT_ZONE
    else
      sm = SystemMessageId::LEFT_COMBAT_ZONE
    end

    characters_inside do |char|
      if battle_started
        char.inside_pvp_zone = true
        if char.player?
          char.send_packet(sm)
        end
      else
        char.inside_pvp_zone = false
        if char.player?
          char.send_packet(sm)
          char.send_packet(ExOlympiadMatchEnd::STATIC_PACKET)
        end
      end
    end
  end

  def parse_loc(x, y, z, type)
    if type && type == "spectatorSpawn"
      @spectator_spawns << Location.new(x, y, z)
    else
      super
    end
  end

  class KickPlayer
    initializer pc: L2PcInstance?

    def call
      if pc = @pc
        if summon = pc.summon
          summon.unsummon(@pc)
        end

        pc.tele_to_location(TeleportWhereType::TOWN)
        pc.instance_id = 0
        @pc = nil
      end
    end
  end

  class Settings < AbstractZoneSettings
    setter task : OlympiadGameTask?

    def clear
      @task = nil
    end

    def olympiad_task : OlympiadGameTask
      @task.not_nil!
    end

    def olympiad_task? : OlympiadGameTask?
      @task
    end
  end

  def settings : Settings
    super.as(Settings)
  end
end
