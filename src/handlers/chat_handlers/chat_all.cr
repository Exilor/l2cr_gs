module ChatHandler::ChatAll
  extend self
  extend ChatHandler

  def handle_chat(type, pc, params, text)
    vcd_used = false

    if text.starts_with?('.')
      st = text.split
      command = ""

      if st.size > 1
        command = st.shift.from(1)
        params = text.from(command.size + 2)
        vch = VoicedCommandHandler[command]
      else
        command = text.from(1)
        debug { "Command: #{command}" }
        vch = VoicedCommandHandler[command]
      end

      if vch
        vch.use_voiced_command(command, pc, params || "")
        vcd_used = true
      else
        debug { "No handler registered for bypass '#{command}'." }
      end
    end

    unless vcd_used
      if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
        pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
        return
      end

      if text.match?(/\\.{1}[^\\.]+/)
        pc.send_packet(SystemMessageId::INCORRECT_SYNTAX)
      else
        cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, pc.appearance.visible_name, text)
        pc.known_list.known_players.each_value do |player|
          if pc.inside_radius?(player, 1250, false, true)
            unless BlockList.blocked?(player, pc)
              player.send_packet(cs)
            end
          end
        end

        pc.send_packet(cs)
      end
    end
  end

  def chat_type_list
    {0}
  end
end
