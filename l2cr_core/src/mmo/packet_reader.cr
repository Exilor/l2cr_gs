class MMO::PacketReader(T)
  include Loggable

  @max_read_per_pass : Int32
  @select_sleep_time : Time::Span

  property! manager : PacketManager(T)

  def initialize(sc : SelectorConfig, @packet_handler : IPacketHandler(T), @packet_executor : IPacketExecutor(T))
    @max_read_per_pass = sc.max_read_per_pass
    @select_sleep_time = sc.select_sleep_time
  end

  def add_connection(con : Connection(T))
    spawn do
      buf = manager.get_pooled_buffer
      buffer_empty = true

      until con.closed?
        if buffer_empty
          if fill_read_buffer(con, buf)
            buffer_empty = read_packets(con, buf)
          end
        else
          buffer_empty = read_packets(con, buf)
        end

        sleep(@select_sleep_time)
      end

      manager.recycle_buffer(buf)

      debug { "#{con.to_log} stopped receiving packets." }
    end
  end

  private def fill_read_buffer(con, buf)
    buffer = uninitialized UInt8[65536]
    result = -2

    begin
      result = con.read(buffer.to_slice)
    rescue
      result = -1
    end

    if result > 0
      buf.write(buffer.to_slice[0, result])
      buf.rewind
      true
    else
      case result
      when 0, -1
        {% if flag?(:preview_mt) %} debug { "closing connection (read result: #{result})" } {% end %}
        manager.close_connection_impl(con)
      when -2
        {% if flag?(:preview_mt) %} debug { "closing connection (read result: #{result})" } {% end %}
        con.client.on_forced_disconnection
        manager.close_connection_impl(con)
      end
      false
    end
  end

  private def read_packets(con, buf)
    # total = 1
    @max_read_per_pass.times do
      if try_read_packet(con, buf)
        # total += 1
      else
        break
      end
    end
    # debug { "Read #{total} packets." if total > 1 }

    if buf.remaining?
      debug "Compacting buffer!"
      buf.compact
      false
    else
      buf.clear
      true
      # recycle?
    end
  end

  private def try_read_packet(con, buffer) : Bool
    remaining = buffer.remaining

    case remaining
    when 0 # nothing to read
    when 1 # need to read more
      debug "Buffer has only 1 byte. Need to read more."
      buffer.compact
      return false
    else
      data_pending = buffer.read_bytes(UInt16).to_i32 - HEADER_SIZE

      if data_pending <= remaining
        if data_pending > 0
          pos = buffer.pos
          parse_client_packet(pos, buffer, data_pending, con.client)
          buffer.pos = pos + data_pending
        end

        unless buffer.remaining?
          # recycle?
          buffer.clear

          return false
        end

        return true
      end
    end

    buffer.pos -= HEADER_SIZE
    buffer.compact

    false
  end

  private def parse_client_packet(position, buffer, data_size, client)
    if client.decrypt(buffer, data_size) && buffer.remaining?
      old_limit = buffer.limit
      buffer.limit = position + data_size
      packet = @packet_handler.handle(buffer, client)
      if packet
        packet.buffer = buffer
        packet.client = client
        if packet.read
          @packet_executor.execute(packet)
        end
      end

      buffer.limit = old_limit
    end
  end
end
