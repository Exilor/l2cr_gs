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
        log { "called command #{command} #{((@config.flood_protection_interval - (@next_game_tick - cur_tick)) * GameTimer::MILLIS_IN_TICK)} ms after previous command." }
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
          end

          @punishment_in_progress = false
        end
      end

      return false
    end

    if @count.get > 0
      if @config.log_flooding?
        log { "issued #{@count.get} extra requests within #{@config.flood_protection_interval * GameTimer::MILLIS_IN_TICK} ms." }
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

    log "kicked for flooding."
  end

  private def ban_account
    punishment = PunishmentTask.new(@client.account_name, PunishmentAffect::ACCOUNT, PunishmentType::BAN, Time.ms + @config.punishment_time, "", self.class.simple_name)
    PunishmentManager.start_punishment(punishment)

    log do
      if @config.punishment_time <= 0
        "banned for flooding forever"
      else
        "banned for flooding for #{@config.punishment_time // 60_000} minutes"
      end
    end
  end

  private def jail_char
    if pc = @client.active_char
      if pc.l2id > 0
        task = PunishmentTask.new(pc.l2id, PunishmentAffect::CHARACTER, PunishmentType::JAIL, Time.ms + @config.punishment_time, "", self.class.simple_name)
        PunishmentManager.start_punishment(task)
      end

      log do
        if @config.punishment_time <= 0
          "jailed for flooding forever"
        else
          "jailed for flooding for #{@config.punishment_time // 60_000} minutes"
        end
      end
    end
  end

  private def log(msg)
    log { msg }
  end

  private def log
    msg = yield
    sb = String::Builder.new(100)
    sb << @config.punishment_type << ": "
    address = @client.connection.ip unless @client.detached?

    case @client.state
    when GameClient::State::JOINING, GameClient::State::IN_GAME
      sb << @client.active_char.not_nil!.name
      sb.print('(', @client.active_char.not_nil!.l2id, ')')
    when GameClient::State::AUTHED
      if account = @client.account_name
        sb << account
      end
    else # CONNECTED
      sb << address if address
    end

    sb << ' ' << msg

    Logs.warn(self, sb.to_s)
  end
end
