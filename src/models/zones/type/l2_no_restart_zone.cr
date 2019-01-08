class L2NoRestartZone < L2ZoneType
  @enabled = true
  property restart_allowed_time : Int32 = 0
  property restart_time : Int32 = 0

  def set_parameter(name, value)
    case name.casecmp
    when "default_enabled"
      @enabled = Bool.new(value)
    when "restartAllowedTime"
      @restart_allowed_time = value.to_i * 1000
    when "restartTime"
      @restart_time = value.to_i * 1000
    when "instanceId"
      # do nothing
    else
      super
    end
  end

  def on_enter(char)
    return unless @enabled

    if char.player?
      char.inside_no_restart_zone = true
    end
  end

  def on_exit(char)
    return unless @enabled

    if char.player?
      char.inside_no_restart_zone = false
    end
  end

  def on_player_login_inside(pc)
    return unless @enabled
    time = Time.ms
    if time - pc.last_access > @restart_time
      if time - GameServer.start_time.ms > @restart_allowed_time
        pc.tele_to_location(TeleportWhereType::TOWN)
      end
    end
  end
end
