module AdminCommandHandler::AdminInstance
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    st = command.split
    st.shift

    if command.starts_with?("admin_createinstance")
      parts = command.split
      if parts.size != 3
        pc.send_message("Example: #createinstance <id> <templatefile> - ids => 300000 are reserved for dynamic instances")
      else
        begin
          id = parts[1].to_i
          if id < 300_000 && InstanceManager.create_instance_from_template(id, parts[2])
            pc.send_message("Instance created.")
          else
            pc.send_message("Failed to create instance.")
          end

          return true
        rescue e
          warn e
          pc.send_message("Failed loading: #{parts[1]} #{parts[2]}")
          return false
        end
      end
    elsif command.starts_with?("admin_listinstances")
      InstanceManager.instances.each_value do |temp|
        pc.send_message("Id: #{temp.id} Name: #{temp.name}")
      end
    elsif command.starts_with?("admin_setinstance")
      begin
        val = st.shift.to_i
        unless InstanceManager.get_instance(val)
          pc.send_message("Instance #{val} doesnt exist.")
          return false
        end

        target = pc.target
        if target.nil? || target.is_a?(L2Summon) # Don't separate summons from masters
          pc.send_message("Incorrect target.")
          return false
        end
        target.instance_id = val
        if target.is_a?(L2PcInstance)
          target.send_message("Admin set your instance to: #{val}")
          target.tele_to_location(target)
        end
        pc.send_message("Moved #{target} to instance #{target.instance_id}.")
        return true
      rescue e
        warn e
        pc.send_message("Use #setinstance id")
      end
    elsif command.starts_with?("admin_destroyinstance")
      begin
        val = st.shift.to_i
        InstanceManager.destroy_instance(val)
        pc.send_message("Instance destroyed")
      rescue e
        warn e
        pc.send_message("Use #destroyinstance id")
      end
    elsif command.starts_with?("admin_ghoston")
      pc.appearance.ghost = true
      pc.send_message("Ghost mode enabled")
      pc.broadcast_user_info
      pc.decay_me
      pc.spawn_me
    elsif command.starts_with?("admin_ghostoff")
      pc.appearance.ghost = false
      pc.send_message("Ghost mode disabled")
      pc.broadcast_user_info
      pc.decay_me
      pc.spawn_me
    end

    true
  end

  def commands : Enumerable(String)
    {
      "admin_setinstance",
      "admin_ghoston",
      "admin_ghostoff",
      "admin_createinstance",
      "admin_destroyinstance",
      "admin_listinstances"
    }
  end
end
