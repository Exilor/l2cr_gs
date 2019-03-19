module L2Cr
  extend self
  include Packets::Outgoing

  @@on_screen_info_task : Runnable::PeriodicTask?
  @@command_line_task : Runnable::PeriodicTask?
  class_property? retry_attacks = false

  def enable_retry
    @@retry_attacks = true
  end

  def disable_retry
    @@retry_attacks = false
  end

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
    extend Runnable

    def run
      L2World.players.each do |pc|
        if pc.online? && !pc.teleporting?
          op = Packets::Outgoing::PcInfo.new(pc)
          # op = Packets::Outgoing::ServerInfo.new
          pc.send_packet(op)
          op = Packets::Outgoing::ZoneInfo.new(pc)
          pc.send_packet(op)
          if pc.target
            pc.send_packet(Packets::Outgoing::TargetInfo.new(pc))
          end
        end
      end
    end
  end

  def command_line_task
    if task = @@command_line_task
      task.cancel
      @@command_line_task = nil
    else
      @@command_line_task = ThreadPoolManager.schedule_general_at_fixed_rate(CommandLineTask, 100, 100)
    end
  end

  private module CommandLineTask
    extend self
    extend Runnable

    def run
      if cmd = STDIN.gets
        print "=> "
        response = handle_cmd(cmd)
        puts response.colorize(:light_magenta)
      end
    end

    private def handle_cmd(cmd : String)
      case cmd
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
        p "#{IdFactory::IDS.@ranges} (#{IdFactory::IDS.@ranges.size})"
      when "retry_attacks"
        if L2Cr.retry_attacks?
          L2Cr.retry_attacks = false
          puts "Attack retrying disabled."
        else
          L2Cr.retry_attacks = true
          puts "Attack retrying enabled."
        end
      when "heal_raids"
        L2World.objects.each do |o|
          if o.is_a?(L2RaidBossInstance)
            if o.current_hp < o.max_hp || o.current_mp < o.max_mp
              puts "Healing #{o.name}"
              o.heal!
            end
          end
        end
      when "check_ids"
        L2Cr.check_ids
      else
        return "unknown command #{cmd.inspect}"
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

























































