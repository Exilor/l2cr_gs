class MMO::PacketWriter(T)
  include Loggable
  include Synchronizable

  private record WriteInfo(T), connection : T, buffer : ByteBuffer

  @connections = Concurrent::Array(Connection(T)).new
  @pending_close = Concurrent::Deque(Connection(T)).new
  @pending_send = Channel(WriteInfo(Connection(T))).new(50)
  @shutdown = false
  @max_send_per_pass : Int32
  @select_sleep_time : Time::Span

  property! manager : PacketManager(T)

  def initialize(sc : SelectorConfig)
    @max_send_per_pass = sc.max_send_per_pass
    @select_sleep_time = sc.select_sleep_time
  end

  def run
    spawn_writer

    until @shutdown
      sync do
        @connections.reverse_each do |con|
          if con.wants_to_write?
            write_packet(con)
          end
        end

        while con = @pending_close.shift?
          {% if flag?(:preview_mt) %} debug { "#{con} to be closed." } {% end %}
          write_close_packet(con)
          close_connection_impl(con)
        end
      end

      sleep(@select_sleep_time)
    end
  end

  private def write_packet(con)
    con.send_queue do |queue|
      if queue.empty?
        return
      end
      buf = manager.get_pooled_buffer

      @max_send_per_pass.times do
        break unless op = queue.shift?
        prepare_write_buffer(con, op, buf)
      end

      loop do
        select
        when @pending_send.send(WriteInfo.new(con, buf))
          break
        else
          # TODO: apply some limit to the number of workers that can be spawned
          spawn_writer
        end
      end

      if queue.empty?
        con.wants_to_write = false
      end
    end
  end

  private def prepare_write_buffer(con, op, buf)
    header_pos = buf.pos
    data_pos = header_pos + HEADER_SIZE
    buf.pos = data_pos

    op.buffer = buf
    op.client = con.client

    begin
      op.write
    rescue e
      error e
    end

    op.buffer = nil

    data_size = buf.pos - data_pos

    buf.pos = data_pos

    begin
      con.client.encrypt(buf, data_size)
    rescue e
      error e
    end

    data_size = buf.pos - data_pos

    buf.pos = header_pos
    buf.write_bytes(data_size.to_u16 + HEADER_SIZE)
    buf.pos = data_pos + data_size
  end

  private def write_close_packet(con)
    buf = nil
    {% if flag?(:preview_mt) %} debug { "Writing close packet for #{con}." } {% end %}
    con.send_queue do |queue|
      while op = queue.shift?
        buf ||= manager.get_pooled_buffer
        prepare_write_buffer(con, op, buf)
        @pending_send.send(WriteInfo.new(con, buf))
      end
    end
    {% if flag?(:preview_mt) %} debug { "Wrote close packet for #{con}." } {% end %}
  end

  def close_connection(con : Connection(T))
    {% if flag?(:preview_mt) %} debug { "close_connection #{con} enter." } {% end %}
    # wrapping this in sync made characters not logout properly
    @pending_close << con
    {% if flag?(:preview_mt) %} debug { "close_connection #{con} exit." } {% end %}
  end

  protected def close_connection_impl(con)
    {% if flag?(:preview_mt) %} debug { "close_connection_impl #{con} enter." } {% end %}
    sync do
      con.client.on_disconnection
      con.close
      @connections.delete_first(con)
    end
    {% if flag?(:preview_mt) %} debug { "close_connection_impl #{con} exit." } {% end %}
  end

  def add_connection(con : Connection(T))
    @connections << con
  end

  private def spawn_writer
    spawn do
      while info = @pending_send.receive?
        con, buf = info.connection, info.buffer
        begin
          con.write(buf.slice[0, buf.pos])
        rescue# e
          # error e
          warn { "#{con} disconnected due to write error." }
          con.client.on_forced_disconnection
          close_connection_impl(con)
        end
        manager.recycle_buffer(buf)
      end
    end
  end

  def close
    @pending_send.close
  end

  def shutdown
    @shutdown = true
  end
end
