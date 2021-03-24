module AdminCommandHandler::AdminExpSp
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_add_exp_sp")
      begin
        val = command.from(16)
        unless admin_add_exp_sp(pc, val)
          pc.send_message("Usage: #add_exp_sp exp sp")
        end
      rescue e
        pc.send_message("Usage: #add_exp_sp exp sp")
      end
    elsif command.starts_with?("admin_remove_exp_sp")
      begin
        val = command.from(19)
        unless admin_remove_exp_sp(pc, val)
          pc.send_message("Usage: #remove_exp_sp exp sp")
        end
      rescue e
        pc.send_message("Usage: #remove_exp_sp exp sp")
      end
    end

    add_exp_sp(pc)
    true
  end

  private def add_exp_sp(pc)
    target = pc.target
    if target.is_a?(L2PcInstance)
      player = target
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/expsp.htm")
    reply["%name%"] = player.name
    reply["%level%"] = player.level
    reply["%xp%"] = player.exp
    reply["%sp%"] = player.sp
    reply["%class%"] = ClassListData.get_class(player.class_id).client_code
    pc.send_packet(reply)
  end

  private def admin_add_exp_sp(pc, exp_sp)
    target = pc.target
    if target.is_a?(L2PcInstance)
      player = target
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return false
    end
    st = exp_sp.split
    if st.size != 2
      return false
    end

    exp = st.shift
    sp = st.shift
    expval = 0i64
    spval = 0
    begin
      expval = exp.to_i64
      spval = sp.to_i
    rescue e
      warn e
      return false
    end
    if expval != 0 || spval != 0
      player.send_message("Admin is adding #{expval} xp and #{spval} sp to you.")
      player.add_exp_and_sp(expval, spval)
      player.broadcast_user_info

      pc.send_message("Added #{expval} xp and #{spval} sp to #{player}.")
      debug { "GM: #{pc}(#{pc.l2id}) added #{expval} xp and #{spval} sp to #{player.l2id}." }
    end

    true
  end

  private def admin_remove_exp_sp(pc, exp_sp)
    target = pc.target

    if target.is_a?(L2PcInstance)
      player = target
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return false
    end
    st = exp_sp.split
    if st.size != 2
      return false
    end

    exp = st.shift
    sp = st.shift
    expval = 0i64
    spval = 0
    begin
      expval = exp.to_i64
      spval = sp.to_i
    rescue e
      warn e
      return false
    end
    if expval != 0 || spval != 0
      # Common character information
      player.send_message("Admin is removing #{expval} xp and #{spval} sp from you.")
      player.remove_exp_and_sp(expval, spval)
      player.broadcast_user_info
      # Admin information
      pc.send_message("Removed #{expval} xp and #{spval} sp from #{player}.")
      debug { "GM: #{pc}(#{pc.l2id}) removed #{expval} xp and #{spval} sp from #{player.l2id}." }
    end

    true
  end

  def commands : Enumerable(String)
    {
      "admin_add_exp_sp_to_character",
      "admin_add_exp_sp",
      "admin_remove_exp_sp"
    }
  end
end
