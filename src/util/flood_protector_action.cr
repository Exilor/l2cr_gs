class FloodProtectorAction
  include Loggable

  @next_game_tick = GameTimer.ticks
  @count = Atomic(Int32).new(0)
  @logged = false
  @punishment_in_progress = false

  initializer client : GameClient, config : Config::FloodProtectorConfig

  def try_perform_action(command : String) : Bool
    if @client.active_char.try &.override_flood_conditions?
      return true
    end

    cur_tick = GameTimer.ticks

    if cur_tick < @next_game_tick || @punishment_in_progress
      if @config.log_flooding? && !@logged
        warn { "Called command #{command} #{((@config.flood_protection_interval - (@next_game_tick - cur_tick)) * GameTimer::MILLIS_IN_TICK)} ms after previous command." }
        @logged = true
      end

      @count.add(1)

      if !@punishment_in_progress && @config.punishment_limit > 0
        if @count.get >= @config.punishment_limit && @config.punishment_type
          @punishment_in_progress = true
          case @config.punishment_type
          when "kick"
            kick_player
          when "ban"
            ban_account
          when "jail"
            jail_char
          else
            # [automatically added else]
          end

          @punishment_in_progress = false
        end
      end

      return false
    end

    if @count.get > 0
      if @config.log_flooding?
        warn { "Issued #{@count.get} extra requests within #{@config.flood_protection_interval * GameTimer::MILLIS_IN_TICK} ms." }
      end
    end

    @next_game_tick = cur_tick + @config.flood_protection_interval
    @logged = false
    @count.set(0)
    true
  end

  private def kick_player
    if pc = @client.active_char
      pc.logout
    else
      @client.close_now
    end

    warn "Kicked for flooding."
  end

  private def ban_account
    punishment = PunishmentTask.new(@client.account_name, PunishmentAffect::ACCOUNT, PunishmentType::BAN, Time.ms + @config.punishment_time, "", self.class.simple_name)
    PunishmentManager.start_punishment(punishment)
  end

  private def jail_char
    if pc = @client.active_char
      char_id = pc.l2id
      if char_id > 0
        task = PunishmentTask.new(char_id, PunishmentAffect::CHARACTER, PunishmentType::JAIL, Time.ms + @config.punishment_time, "", self.class.simple_name)
        PunishmentManager.start_punishment(task)
      end
      warn { "#{pc.name} jailed for flooding." }
    end
  end

  private def log(msg)
    super
    # TODO (or not)
  end
end
