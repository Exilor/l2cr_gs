module L2Cr
  extend self
  include Packets::Outgoing

  @@on_screen_info_task : TaskScheduler::PeriodicTask?
  @@command_line_task : TaskScheduler::PeriodicTask?

  def on_screen_info_task
    if task = @@on_screen_info_task
      task.cancel
      @@on_screen_info_task = nil
    else
      @@on_screen_info_task = ThreadPoolManager.schedule_general_at_fixed_rate(OnScreenInfoTask, 100, 100)
    end
  end

  private module OnScreenInfoTask
    extend self

    def call
      L2World.players.each do |pc|
        if pc.online? && !pc.teleporting?
          op = Packets::Outgoing::PcInfo.new(pc)
          # op = Packets::Outgoing::ServerInfo.new
          pc.send_packet(op)
          op = Packets::Outgoing::ZoneInfo.new(pc)
          pc.send_packet(op)
          if target = pc.target
            pc.send_packet(Packets::Outgoing::TargetInfo.new(pc, target))
          end
        end
      end
    end
  end

  def command_line_task
    spawn do
      while cmd = STDIN.gets.try &.chomp
        print "=> "
        begin
          response = CommandLineTask.handle_cmd(cmd)
          puts response.colorize(:light_magenta)
        rescue e
          puts e.inspect_with_backtrace.colorize(:red)
        end
      end
    end
  end

  private module CommandLineTask
    extend self

    @@last_cmd = ""

    def handle_cmd(cmd : String)
      case cmd
      when "\eOA"
        handle_cmd(@@last_cmd)
      when "info"
        L2Cr.on_screen_info_task
      when /^shutdown\s\d+/
        Shutdown.start_shutdown(nil, cmd.split[1].to_i, false)
      when "shutdown"
        Shutdown.start_shutdown(nil, 0, false)
      when /^restart\s\d+/
        Shutdown.start_shutdown(nil, cmd.split[1].to_i, true)
      when "restart"
        Shutdown.start_shutdown(nil, 0, true)
      when "ids"
        puts "#{IdFactory::IDS.ranges} (#{IdFactory::IDS.ranges.size} ranges)"
      when "check_ids"
        L2Cr.check_ids
      when /^valakas\s\w+$/
        if q = QuestManager.get_quest("Valakas")
          if valakas = L2World.objects.find { |o| o.id == 29028 }
            event = cmd.split.last
            q.on_adv_event(event, valakas.as(L2GrandBossInstance), nil)
          else
            puts "Valakas not found."
          end
        else
          puts "Valakas quest not found."
        end
      when /gm\s\w+/
        name = cmd.split.last

        if pc = L2World.get_player(name)
          if pc.gm?
            pc.access_level = 0
          else
            pc.access_level = 8
          end
        else
          puts "Player '#{name}' not found in game."
          # sql = "UPDATE characters SET accesslevel=? WHERE char_name=?"
          # GameDB.exec(sql, 8, name)
        end
      when "uptime"
        puts Time.local - GameServer.start_time
      else
        return "unknown command '#{cmd}'"
      end

      if !cmd.empty? && cmd != "\eOA"
        @@last_cmd = cmd
      end

      nil
    end
  end

  protected def check_ids
    errors = 0
    L2World.regions.flat_each do |reg|
      reg.objects.each do |l2id, obj|
        unless L2World.find_object(l2id)
          errors &+= 1
          puts "#{obj} with object id #{l2id} found in region #{reg} but not in L2World."
        end
      end
    end
    errors = "No" if errors == 0
    puts "#{errors} errors."
  end
end
