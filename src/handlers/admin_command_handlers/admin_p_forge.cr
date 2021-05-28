module AdminCommandHandler::AdminPForge
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    if command == "admin_forge"
      show_main_page(pc)
    elsif command.starts_with?("admin_forge_values ")
      begin
        st = command.split
        st.shift? # skip command token

        unless st.empty?
          show_values_usage(pc)
          return false
        end

        opcodes = get_opcodes(st)
        unless opcodes && validate_opcodes(opcodes)
          pc.send_message("Invalid op codes")
          show_values_usage(pc)
          return false
        end

        unless st.empty?
          format = st.shift
          unless validate_format(format)
            pc.send_message("Format invalid")
            show_values_usage(pc)
            return false
          end
        end

        show_values_page(pc, opcodes, format)
      rescue e
        warn e
        show_values_usage(pc)
        return false
      end
    elsif command.starts_with?("admin_forge_send ")
      begin
        st = command.split
        st.shift

        unless st.empty?
          show_send_usage(pc, nil, nil)
          return false
        end

        method = st.shift
        unless validate_method(method)
          pc.send_message("Invalid method")
          show_send_usage(pc, nil, nil)
          return false
        end

        opcodes = st.shift.split(';')
        unless validate_opcodes(opcodes)
          pc.send_message("Invalid op codes")
          show_send_usage(pc, nil, nil)
          return false
        end

        unless st.empty?
          format = st.shift
          unless validate_format(format)
            pc.send_message("Invalid format")
            show_send_usage(pc, nil, nil)
            return false
          end
        end

        afp = nil
        bb = nil

        opcodes.size.times do |i|
          if i == 0
            type = 'c'
          elsif i == 1
            type = 'h'
          else
            type = 'd'
          end
          case method
          when "sc", "sb"
            afp ||= AdminForgePacket.new
            afp.add_part(type, opcodes[i])
          else
            unless bb
              bb = ByteBuffer.new(32767)
              bb.set_encoding("UTF-16LE")
            end
            write(type, opcodes[i], bb)
          end
        end

        if format
          format.size.times do |i|
            if st.empty?
              pc.send_message("Not enough values")
              show_send_usage(pc, nil, nil)
              return false
            end

            target = nil
            boat = nil
            value = st.shift
            case value
            when "$oid"
              value = pc.l2id.to_s
            when "$boid"
              if boat = pc.boat
                value = boat.l2id.to_s
              else
                value = "0"
              end
            when "$title"
              value = pc.title
            when "$name"
              value = pc.name
            when "$x"
              value = pc.x.to_s
            when "$y"
              value = pc.y.to_s
            when "$z"
              value = pc.z.to_s
            when "$heading"
              value = pc.heading.to_s
            when "$toid"
              value = pc.target_id.to_s
            when "$tboid"
              target = pc.target
              if target.is_a?(L2Playable) && (target_pc = target.acting_player)
                if boat = target_pc.boat
                  value = boat.l2id.to_s
                else
                  value = "0"
                end
              end
            when "$ttitle"
              target = pc.target
              if target = pc.target.as?(L2Character)
                value = target.title
              else
                value = ""
              end
            when "$tname"
              if target = pc.target
                value = target.name.to_s
              else
                value = ""
              end
            when "$tx"
              if target = pc.target
                value = target.x.to_s
              else
                value = "0"
              end
            when "$ty"
              if target = pc.target
                value = target.y.to_s
              else
                value = "0"
              end
            when "$tz"
              if target = pc.target
                value = target.z.to_s
              else
                value = "0"
              end
            when "$theading"
              if target = pc.target
                value = target.heading.to_s
              else
                value = "0"
              end
            end

            case method
            when "sc", "sb"
              if afp
                afp.add_part(format[i], value)
              end
            else
              write(format[i], value, bb)
            end
          end
        end

        if method == "sc"
          pc.send_packet(afp) if afp
        elsif method == "sb"
          pc.broadcast_packet(afp) if afp
        elsif bb
          bb.rewind
          if packet = GamePacketHandler.handle(bb, pc.client.not_nil!)
            packet.buffer = bb
            packet.client = pc.client
            if packet.read
              ThreadPoolManager.execute_packet(->packet.run)
            end
          end
        end

        show_values_page(pc, opcodes, format)
      rescue e
        warn e
        show_send_usage(pc, nil, nil)
        return false
      end
    end

    true
  end

  private def write(b, string, buf)
    return false unless buf
    case b
    when 'C', 'c'
      buf.write_byte(string.to_u8)
    when 'D', 'd'
      buf.write_bytes(string.to_i32)
    when 'H', 'h'
      buf.write_bytes(string.to_i16)
    when 'F', 'f'
      buf.write_bytes(string.to_f64)
    when 'S', 's'
      buf << string
      buf.write_bytes(0u16)
    when 'B', 'b', 'X', 'x'
      buf.write(string.to_slice)
    when 'Q', 'q'
      buf.write_bytes(string.to_i64)
    else
      return false
    end

    true
  end

  private def get_opcodes(st)
    opcodes = nil
    st.each do |token|
      if token == ";"
        break
      end

      opcodes ||= [] of String
      opcodes << token
    end

    opcodes
  end

  private def validate_opcodes(opcodes)
    if opcodes.nil? || (opcodes.empty? || opcodes.size > 3)
      return false
    end

    opcodes.each_with_index do |opcode, i|
      unless opcode_long = opcode.to_i64?
        if i > 0
          return true
        end

        return false
      end

      if opcode_long < 0
        return false
      end

      if i == 0 && opcode_long > 255
        return false
      elsif i == 1 && opcode_long > 65535
        return false
      elsif i == 2 && opcode_long > 4294967295
        return false
      end
    end

    true
  end

  private def validate_format(format)
    format.each_char do |char|
      case char
      when 'b', 'B', 'x', 'X'
        # array
      when 'c', 'C'
        # byte
      when 'h', 'H'
        # word
      when 'd', 'D'
        # dword
      when 'q', 'Q'
        # qword
      when 'f', 'F'
        # double
      when 's', 'S'
        # string
      else
        return false
      end
    end

    true
  end

  private def validate_method(method)
    method.in?("sc", "sb", "cs")
  end

  private def show_values_usage(pc)
    pc.send_message("Usage: #forge_values opcode1[ opcode2[ opcode3]] ;[ format]")
    show_main_page(pc)
  end

  private def show_send_usage(pc, opcodes, format)
    pc.send_message("Usage: #forge_send sc|sb|cs opcode1[;opcode2[;opcode3]][ format value1 ... valueN] ")
    if opcodes.nil?
      show_main_page(pc)
    else
      show_values_page(pc, opcodes, format)
    end
  end

  private def show_main_page(pc)
    AdminHtml.show_admin_html(pc, "pforge/main.htm")
  end

  private def show_values_page(pc, opcodes, format)
    send_bypass = nil
    values_html = HtmCache.get_htm_force(pc, "data/html/admin/pforge/values.htm")
    if opcodes.size == 3
      values_html = values_html.sub("%opformat%", "chd")
      send_bypass = "#{opcodes[0]};#{opcodes[1]};#{opcodes[2]}"
    elsif opcodes.size == 2
      values_html = values_html.sub("%opformat%", "ch")
      send_bypass = "#{opcodes[0]};#{opcodes[1]}"
    else
      values_html = values_html.sub("%opformat%", "c")
      send_bypass = opcodes[0]
    end

    values_html = values_html.sub("%opcodes%", send_bypass)

    editors_html = ""

    if format.nil?
      values_html = values_html.sub("%format%", "")
      editors_html = ""
    else
      values_html = values_html.sub("%format%", format)
      send_bypass += " " + format

      editor_template = HtmCache.get_htm(pc, "data/html/admin/pforge/inc/editor.htm")

      if editor_template
        single_char_sequence = [] of Char
        single_char_sequence << ' '

        format.size.times do |i|
          ch = format[i]
          single_char_sequence.insert(0, ch)
          editors_html += editor_template.sub("%format%", single_char_sequence.join).sub("%editor_index%", i.to_s)
          send_bypass += " $v#{i}"
        end
        else
          editors_html = ""
      end
    end

    values_html = values_html.sub("%editors%", editors_html)
    values_html = values_html.sub("%send_bypass%", send_bypass)
    pc.send_packet(NpcHtmlMessage.new(values_html))
  end

  def commands : Enumerable(String)
    {
      "admin_forge",
      "admin_forge_values",
      "admin_forge_send"
    }
  end
end
