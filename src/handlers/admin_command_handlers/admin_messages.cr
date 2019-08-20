module AdminCommandHandler::AdminMessages
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_msg ")
      begin
        sm_id = command.from(10).strip.to_i
        sm = Packets::Outgoing::SystemMessage[sm_id]
        pc.send_packet(sm)
        return true
      rescue e
        warn e
        pc.send_message("Command format: #msg <SYSTEM_MSG_ID>")
      end
    elsif command.starts_with?("admin_msgx ")
      tokens = command.split
      if tokens.size <= 2 || !tokens[1].num?
        pc.send_message("Command format: #msgx <SYSTEM_MSG_ID> [item:Id] [skill:Id] [npc:Id] [zone:x,y,x] [castle:Id] [str:'text']")
        return false
      end

      sm = Packets::Outgoing::SystemMessage[tokens[1].to_i]
      last_pos = 0
      tokens.each do |val|
        begin
          if val.starts_with?("item:")
            sm.add_item_name(val.from(5).to_i)
          elsif val.starts_with?("skill:")
            sm.add_skill_name(val.from(6).to_i)
          elsif val.starts_with?("npc:")
            sm.add_npc_name(val.from(4).to_i)
          elsif val.starts_with?("zone:")
            x = val[5...val.index(",").not_nil!].to_i
            y = val[val.index(",").not_nil! + 1...val.rindex(",").not_nil!].to_i
            z = val[val.rindex(",").not_nil! + 1...val.size].to_i
            sm.add_zone_name(x, y, z)
          elsif val.starts_with?("castle:")
            sm.add_castle_id(val.from(7).to_i)
          elsif val.starts_with?("str:")
            pos = command.index("'", last_pos + 1).not_nil!
            last_pos = command.index("'", pos + 1).not_nil!
            sm.add_string(command[pos + 1...last_pos])
          end
        rescue e
          warn e
          pc.send_message("Exception: #{e.message}")
          next
        end
      end
      pc.send_packet(sm)
    end

    false
  end

  def commands
    {
      "admin_msg",
      "admin_msgx"
    }
  end
end
