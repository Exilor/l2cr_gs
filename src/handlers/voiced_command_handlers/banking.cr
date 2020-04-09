module VoicedCommandHandler::Banking
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"bank", "withdraw", "deposit"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    case cmd
    when "bank"
      msg = ".deposit (#{Config.banking_system_adena} Adena = #{Config.banking_system_goldbars} Goldbar) / .withdraw (#{Config.banking_system_goldbars} Goldbar = #{Config.banking_system_adena} Adena)"
      pc.send_message(msg)
    when "deposit"
      if pc.inventory.get_inventory_item_count(57, 0) >= Config.banking_system_adena
        unless pc.reduce_adena("Goldbar", Config.banking_system_adena, pc, false)
          return false
        end

        pc.inventory.add_item("Goldbar", 3470, Config.banking_system_goldbars, pc, nil)
        pc.inventory.update_database
        pc.send_message("You now have #{Config.banking_system_goldbars} Goldbar(s), and #{Config.banking_system_adena} less adena.")
      else
        pc.send_message("You do not have enough Adena to convert to Goldbar(s), you need #{Config.banking_system_adena} Adena.")
      end
    when "withdraw"
      if pc.inventory.get_inventory_item_count(3470, 0) >= Config.banking_system_goldbars
        unless pc.destroy_item_by_item_id("Adena", 3470, Config.banking_system_goldbars, pc, false)
          return false
        end

        pc.inventory.add_adena("Adena", Config.banking_system_adena, pc, nil)
        pc.inventory.update_database
        pc.send_message("You now have #{Config.banking_system_adena} Adena, and #{Config.banking_system_goldbars} less Goldbar(s).")
      else
        pc.send_message("You do not have any Goldbars to turn into #{Config.banking_system_adena} Adena.")
      end
    else
      # [automatically added else]
    end


    true
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
