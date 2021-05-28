module AdminCommandHandler::AdminDelete
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    if command == commands[0]
      handle_delete(pc)
    end

    true
  end

  private def handle_delete(pc)
    case target = pc.target
    when L2Npc
      target.delete_me

      if sp = target.spawn?
        sp.stop_respawn
        if RaidBossSpawnManager.defined?(sp.id)
          RaidBossSpawnManager.delete_spawn(sp, true)
        else
          SpawnTable.delete_spawn(sp, true)
        end
      end

      pc.send_message("Deleted #{target} from #{target.l2id}.")
    else
      unless target.is_a?(L2PcInstance)
        if target.responds_to?(:delete_me)
          target.delete_me
          pc.send_message("Deleted #{target} from #{target.l2id}.")
          return
        end
      end

      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
    end
  end

  def commands : Enumerable(String)
    {"admin_delete"}
  end
end
