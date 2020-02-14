module VoicedCommandHandler::ChangePassword
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"changepassword"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    if !params.empty?
      st = params.split
      begin
        unless st.empty?
          current_password = st.shift
        end
        unless st.empty?
          new_password = st.shift
        end
        unless st.empty?
          repeat_new_password = st.shift
        end

        if current_password && new_password && repeat_new_password
          if new_password != repeat_new_password
            pc.send_message("The new password doesn't match with the repeated one.")
            return false
          end

          if new_password.size < 3
            pc.send_message("Passwords must be longer than 3 characters.")
            return false
          end

          if new_password.size > 30
            pc.send_message("Passwords must be shorter than 30 characters.")
            return false
          end

          LoginServerClient.send_change_password(pc.account_name, pc.name, current_password, new_password)
        else
          pc.send_message("Invalid password. You have to fill all the boxes.")
          return false
        end
      rescue e
        pc.send_message("A problem occurred while changing your password.")
        warn e
      end
    else
      html = HtmCache.get_htm("en", "data/html/mods/ChangePassword.htm")
      html ||= "<html><body><br><br><center><font color=LEVEL>404:</font> File Not Found</center></body></html>"
      pc.send_packet(NpcHtmlMessage.new(html))
    end

    true
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
