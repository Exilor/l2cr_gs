module AdminCommandHandler::AdminMammon
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    teleport_index = -1
    black_sp = AutoSpawnHandler.get_auto_spawn_instance(SevenSigns::MAMMON_BLACKSMITH_ID, false)
    merch_sp = AutoSpawnHandler.get_auto_spawn_instance(SevenSigns::MAMMON_MERCHANT_ID, false)

    if command.starts_with?("admin_mammon_find")
      begin
        if command.size > 17
          teleport_index = command.from(18).to_i
        end
      rescue e
        warn e
        pc.send_message("Usage: #mammon_find [teleportIndex] (where 1 = Blacksmith, 2 = Merchant)")
        return false
      end

      unless SevenSigns.instance.seal_validation_period?
        pc.send_packet(SystemMessageId::SSQ_COMPETITION_UNDERWAY)
        return false
      end

      if black_sp
        if b = black_sp.npc_instance_list.first?
          pc.send_message("Blacksmith of Mammon: #{b.x} #{b.y} #{b.z}")
          if teleport_index == 1
            pc.tele_to_location(b.location, true)
          end
        end
      else
        pc.send_message("Blacksmith of Mammon isn't registered for spawn.")
      end

      if merch_sp
        if m = merch_sp.npc_instance_list.first?
          pc.send_message("Merchant of Mammon: #{m.x} #{m.y} #{m.z}")
          if teleport_index == 2
            pc.tele_to_location(m.location, true)
          end
        end
      else
        pc.send_message("Merchant of Mammon isn't registered for spawn.")
      end
    elsif command.starts_with?("admin_mammon_respawn")
      unless SevenSigns.instance.seal_validation_period?
        pc.send_packet(SystemMessageId::SSQ_COMPETITION_UNDERWAY)
        return true
      end

      if merch_sp
        merch_respawn = AutoSpawnHandler.get_time_to_next_spawn(merch_sp)
        pc.send_message("The Merchant of Mammon will respawn in #{merch_respawn // 60000} minute(s).")
      else
        pc.send_message("Merchant of Mammon isn't registered for spawn.")
      end

      if black_sp
        black_respawn = AutoSpawnHandler.get_time_to_next_spawn(black_sp)
        pc.send_message("The Blacksmith of Mammon will respawn in #{black_respawn // 60000} minute(s).")
      else
        pc.send_message("Blacksmith of Mammon isn't registered for spawn.")
      end
    end

    true
  end

  def commands
    {
      "admin_mammon_find",
      "admin_mammon_respawn"
    }
  end
end
