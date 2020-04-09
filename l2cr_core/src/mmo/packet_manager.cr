require "./selector_config"

class MMO::PacketManager(T)
  include Cancellable
  include Loggable

  @helper_buffer_size : Int32
  @helper_buffer_count : Int32
  @tcp_no_delay : Bool

  property host : String = ""
  property port : Int32 = 0

  def initialize(sc : SelectorConfig, *, @client_factory : IClientFactory(T), @packet_handler : IPacketHandler(T), @packet_executor : IPacketExecutor(T), @accept_filter : IAcceptFilter)
    @reader = PacketReader(T).new(sc, packet_handler, packet_executor)
    @writer = PacketWriter(T).new(sc)
    @helper_buffer_size = sc.helper_buffer_size
    @helper_buffer_count = sc.helper_buffer_count
    @tcp_no_delay = sc.tcp_no_delay
    @buffers = Concurrent::Array(ByteBuffer).new(@helper_buffer_count)
    @reader.manager = self
    @writer.manager = self
  end

  def run
    server = TCPServer.new(@host, @port)

    spawn @writer.run

    until cancelled?
      spawn process_connection(server.accept)
    end
  ensure
    server.try &.close
  end

  def close_connection(con : Connection(T))
    {% if flag?(:preview_mt) %} debug { "Closing connection #{con}." } {% end %}
    @writer.close_connection(con)
    {% if flag?(:preview_mt) %} debug { "Connection #{con} closed." } {% end %}
  end

  private def process_connection(socket)
    unless @accept_filter.accept?(socket)
      debug { "#{socket} rejected by #{@accept_filter}." }
      socket.close rescue nil
      return
    end
    con = Connection(T).new(self, socket, @tcp_no_delay)
    {% if flag?(:preview_mt) %} debug { "#{con} connected." } {% end %}
    client = @client_factory.create(con)
    con.client = client
    {% if flag?(:preview_mt) %} debug { "Adding connection #{con} to the PacketWriter." } {% end %}
    @writer.add_connection(con)
    {% if flag?(:preview_mt) %} debug { "Adding connection #{con} to the PacketReader." } {% end %}
    @reader.add_connection(con)
    {% if flag?(:preview_mt) %} debug { "Connection #{con} added to PacketWriter and PacketReader." } {% end %}
  end

  protected def close_connection_impl(con : Connection(T))
    {% if flag?(:preview_mt) %} debug { "Closing connection (impl) #{con}." } {% end %}
    @writer.close_connection_impl(con)
    {% if flag?(:preview_mt) %} debug { "Connection #{con} closed (impl)." } {% end %}
  end

  protected def get_pooled_buffer
    @buffers.pop do
      buf = ByteBuffer.new
      buf.set_encoding("UTF-16LE")
      buf
    end
  end

  protected def recycle_buffer(buf)
    if @buffers.size < @helper_buffer_count
      buf.clear
      @buffers << buf
    end
  end

  def shutdown
    @writer.shutdown
  end
end
