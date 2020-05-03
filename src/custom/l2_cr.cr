module L2Cr
  extend self
  include Packets::Outgoing

  @@on_screen_info_task : TaskExecutor::Scheduler::PeriodicTask?
  @@command_line_task : TaskExecutor::Scheduler::PeriodicTask?

  def on_screen_info_task
    if task = @@on_screen_info_task
      task.cancel
      @@on_screen_info_task = nil
    else
      @@on_screen_info_task = ThreadPoolManager.schedule_general_at_fixed_rate(OnScreenInfoTask, 10, 10)
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
        response = CommandLineTask.handle_cmd(cmd)
        puts response.colorize(:light_magenta)
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
        puts "#{IdFactory::IDS.@ranges} (#{IdFactory::IDS.@ranges.size} ranges)"
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
      when "pool_stats"
        puts ThreadPoolManager.stats
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
    L2World.world_regions.each &.each do |reg|
      reg.objects.each do |l2id, obj|
        unless L2World.find_object(l2id)
          errors += 1
          puts "#{obj} with object id #{l2id} found in region #{reg} but not in L2World."
        end
      end
    end
    errors = "No" if errors == 0
    puts "#{errors} errors."
  end

  def test(pc)
    # app = PcAppearance.new(rand(4u8), rand(4u8), rand(4u8), false)
    # app.visible_name = Time.ms.to_s
    # app.name_color = PcAppearance::DEFAULT_TITLE_COLOR
    # fake = L2PcInstance.new(ClassId::FIGHTER.to_i, "", app)
    # fake.location = pc.location
    # fake.spawn_me

    # pc.send_packet(Packets::Outgoing::ShowBoard.new("<html><body><br><center>Error: HTML was too long!</center></body></html>", "101"))
    # pc.send_packet(Packets::Outgoing::ShowBoard.new(nil, "102"))
    # pc.send_packet(Packets::Outgoing::ShowBoard.new(nil, "103"))

    # pc.send_packet(SystemMessageId::NAMING_YOU_CANNOT_SET_NAME_OF_THE_PET) # doesnt work
    # pc.send_packet(SystemMessage.naming_you_cannot_set_name_of_the_pet) # doesnt work
  end
end
