class Shutdown
  include Loggable
  include Packets::Outgoing

  private SIGTERM = 0
  private GM_SHUTDOWN = 1
  private GM_RESTART = 2
  private ABORT = 3
  private MODE_TEXT = {"SIGTERM", "shutting down", "restarting", "aborting"}

  @@counter_instance : self?

  protected getter shutdown_mode : Int32

  def initialize
    @seconds_shut = -1
    @shutdown_mode = SIGTERM
  end

  def initialize(seconds : Int32, restart : Bool)
    @seconds_shut = Math.max(seconds, 0)
    @shutdown_mode = restart ? GM_RESTART : GM_SHUTDOWN
  end

  def send_server_quit(seconds)
    sm = SystemMessage.the_server_will_be_coming_down_in_s1_seconds
    sm.add_int(seconds)
    debug { "#{MODE_TEXT[@shutdown_mode].capitalize} in #{seconds} s." }
    Broadcast.to_all_online_players(sm)
  end

  def start_telnet_shutdown(ip, seconds, restart)
    warn { "IP #{ip} issued shutdown command. #{MODE_TEXT[@shutdown_mode]} in #{seconds} s." }

    @shutdown_mode = restart ? GM_RESTART : GM_SHUTDOWN

    if @shutdown_mode > 0
      case seconds
      when 1..5, 10, 30, 60, 120, 180, 240, 300, 420, 480, 540
        # do nothing
      else
        send_server_quit(seconds)
      end
    end

    @@counter_instance.try &.abort
    @@counter_instance = inst = Shutdown.new(seconds, restart)
    inst.start
  end

  def start
    spawn { run }
  end

  def telnet_abort(ip)
    warn { "IP #{ip} issued shutdown ABORT. #{MODE_TEXT[@shutdown_mode]} has been stopped." }

    if ci = @@counter_instance
      ci.abort
      Broadcast.to_all_online_players("Server aborts #{MODE_TEXT[@shutdown_mode]}.", false)
    end
  end

  def run
    tc1 = Timer.new
    tc2 = Timer.new

    if self == Shutdown.instance
      tc1.start

      if Config.offline_trade_enable || Config.offline_craft_enable
        if Config.restore_offliners
          begin
            OfflineTradersTable.store_offliners
            info { "Offline traders stored in #{tc1}." }
            tc1.start
          rescue e
            error e
          end
        end
      end

      begin
        disconnect_all_characters
        info { "All players disconnected and saved (#{tc1})." }
        tc1.start
      rescue e
        error e
      end

      begin
        GameTimer.cancel
        info { "GameTimer stopped (#{tc1})." }
        tc1.start
      rescue e
        error e
      end

      begin
        LoginServerThread.instance.terminate
        info { "LoginServerThread terminated (#{tc1})." }
        tc1.start
      rescue e
        error e
      end

      save_data
      tc1.start

      begin
        GameServer.close_selector
        GameServer.info { "Selector thread has been shut down (#{tc1})." }
        tc1.start
      rescue e
        error e
      end

      debug "Shutting down the thread pool..."
      ThreadPoolManager.shutdown

      begin
        GameDB.close
        info { "Database connection closed (#{tc1})." }
      rescue e
        error e
      end
      tc1.start

      info { "The server has been shut down in #{tc2} seconds." }

      if Shutdown.instance.shutdown_mode == GM_RESTART
        exit(2)
      else
        exit(0)
      end
    else
      countdown
      warn { "GM shutdown countdown is over. #{MODE_TEXT[@shutdown_mode]}." }
      case @shutdown_mode
      when GM_SHUTDOWN
        Shutdown.instance.mode = GM_SHUTDOWN
        exit(0)
      when GM_RESTART
        Shutdown.instance.mode = GM_RESTART
        exit(2)
      when ABORT
        LoginServerThread.instance.server_status = ServerStatus::STATUS_AUTO
      end
    end
  end

  def start_shutdown(pc, seconds, restart)
    @shutdown_mode = restart ? GM_RESTART : GM_SHUTDOWN

    warn { "GM #{pc.try &.name} issued #{MODE_TEXT[@shutdown_mode]} in #{seconds} seconds." }

    if @shutdown_mode > 0
      case seconds
      when 1..5, 10, 30, 60, 120, 180, 240, 300, 420, 480, 540
      else
        send_server_quit(seconds)
      end
    end

    @@counter_instance.try &.abort
    @@counter_instance = inst = Shutdown.new(seconds, restart)
    inst.start
  end

  def abort(pc = nil)
    if pc
      warn { "GM #{pc} aborted the #{MODE_TEXT[@shutdown_mode]}." }
      if inst = @@counter_instance
        inst.abort
        msg = "Server aborts #{MODE_TEXT[@shutdown_mode]}."
        Broadcast.to_all_online_players(msg, false)
      end
    else
      @shutdown_mode = ABORT
    end
  end

  def mode=(mode)
    @shutdown_mode = mode
  end

  def countdown
    while @seconds_shut > 0
      case @seconds_shut
      when 1..5, 10, 30, 120, 180, 240, 300, 420, 480, 540
        send_server_quit(@seconds_shut)
      when 60
        LoginServerThread.instance.server_status = ServerStatus::STATUS_DOWN
        send_server_quit(60)
      end

      @seconds_shut &-= 1

      sleep 1

      break if @shutdown_mode == ABORT
    end
  rescue e
    warn e
  end

  private def save_data
    case @shutdown_mode
    when SIGTERM
      info "SIGTERM received. Shutting down now."
    when GM_SHUTDOWN
      info "GM shutdown received. Shutting down now."
    when GM_RESTART
      info "GM restart received. Restarting now."
    end

    tc = Timer.new

    unless SevenSigns.instance.seal_validation_period?
      SevenSignsFestival.instance.save_festival_data(false)
      info { "Festival data saved in #{tc} seconds." }
      tc.start
    end

    SevenSigns.instance.save_seven_signs_data
    info { "Seven Signs data saved in #{tc} seconds." }
    tc.start

    SevenSigns.instance.save_seven_signs_status
    info { "Seven Signs status saved in #{tc} seconds." }
    tc.start

    RaidBossSpawnManager.clean_up
    info { "Raid boss info saved in #{tc}." }
    tc.start

    GrandBossManager.clean_up
    info { "Grand boss info saved in #{tc} seconds." }
    tc.start

    ItemAuctionManager.shutdown
    info { "Item auctions saved in #{tc} seconds." }
    tc.start

    Olympiad.instance.save_olympiad_status
    info { "Olympiad data saved in #{tc} seconds." }
    tc.start

    Hero.shutdown
    info { "Hero data saved in #{tc} seconds." }
    tc.start

    ClanTable.store_clan_score
    info { "Clan data saved in #{tc} seconds." }
    tc.start

    CursedWeaponsManager.save_data
    info { "Cursed weapons data saved in #{tc} seconds." }
    tc.start

    unless Config.alt_manor_save_all_actions
      CastleManorManager.store_me
      info { "Manor data saved in #{tc} seconds." }
      tc.start
    end

    ClanHallSiegeManager.on_server_shutdown
    info { "Siegable hall attacker lists saved in #{tc} seconds." }
    tc.start

    QuestManager.save
    info { "QuestManager data saved in #{tc} seconds." }
    tc.start

    GlobalVariablesManager.instance.store_me
    info { "Global variables saved in #{tc} seconds." }
    tc.start

    if Config.save_dropped_item
      ItemsOnGroundManager.save_in_db
      info { "Dropped items saved in #{tc} seconds." }
      tc.start
      ItemsOnGroundManager.clean_up
      info { "Dropped items cleaned up in #{tc} seconds." }
      tc.start
    end

    if Config.botreport_enable
      BotReportTable.save_reported_char_data
      info { "Bot reports saved in #{tc} seconds." }
      tc.start
    end
  end

  private def disconnect_all_characters
    L2World.players.each do |pc|
      begin
        client = pc.client
        if client && !client.detached?
          client.close(ServerClose::STATIC_PACKET)
          client.active_char = nil
          pc.client = nil
        end
        pc.delete_me
      rescue e
        error { "Error disconnecting #{pc}." }
        error e
      end
    end
  end

  def self.instance
    @@instance ||= new
  end

  def self.run
    instance.run
  end

  def self.start_shutdown(*args)
    instance.start_shutdown(*args)
  end

  def self.abort(pc = nil)
    instance.abort(pc) if @@instance
  end

  def to_s(io : IO)
    io << {{@type.stringify}}
  end
end
