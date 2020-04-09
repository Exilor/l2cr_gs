require "socket"
require "./outgoing_packet"

class MMO::Connection(T) < IO
  include Loggable

  @send_queue = Deque(OutgoingPacket(T)).new
  @send_queue_mutex = MyMutex.new
  @pending_close = false

  getter address : Socket::IPAddress
  property! client : T?
  property? wants_to_write : Bool = false

  def initialize(@manager : PacketManager(T), @socket : TCPSocket, tcp_nodelay : Bool)
    @address = @socket.remote_address
    begin
      @socket.tcp_nodelay = tcp_nodelay
    rescue e
      error "Couldn't set tcp_nodelay."
      error e
    end
  end

  def write(*args) : Nil
    @socket.write(*args)
  end

  def read(*args)
    @socket.read(*args)
  end

  def ip : String
    @address.address
  end

  def send_packet(op : OutgoingPacket(T))
    if @pending_close
      return
    end

    send_queue do |queue|
      queue << op
      @wants_to_write = true
    end
  end

  def close
    @pending_close = true
  end

  def close(op : OutgoingPacket(T)?)
    close({op})
  end

  def close(packets : Enumerable(OutgoingPacket(T)?))
    send_queue do |queue|
      unless @pending_close
        @pending_close = true
        queue.clear
        unless packets.empty?
          debug { "Closing with packets: #{packets.map &.class}." }
          packets.each { |op| queue << op if op }
          @manager.close_connection(self)
        end
      end
    end

    @wants_to_write = false
  end

  def closed? : Bool
    @pending_close
  end

  def send_queue(&block : Deque(OutgoingPacket(T)) ->)
    @send_queue_mutex.synchronize { yield @send_queue }
  end
end


# class MMO::Connection(T) < IO
#   include Loggable

#   @send_queue_mutex = Mutex.new(:Reentrant)
#   @pending_close = false

#   getter send_queue
#   getter address : Socket::IPAddress
#   property! client : T?

#   def initialize(@manager : PacketManager(T), @socket : TCPSocket, tcp_nodelay : Bool)
#     @send_queue = Channel(OutgoingPacket(T)?).new(50)
#     @address = @socket.remote_address
#     begin
#       @socket.tcp_nodelay = tcp_nodelay
#     rescue e
#       error "Couldn't set tcp_nodelay."
#       error e
#     end
#   end

#   def write(*args) : Nil
#     @socket.write(*args)
#   end

#   def read(*args)
#     @socket.read(*args)
#   end

#   def ip : String
#     @address.address
#   end

#   def send_packet(op : OutgoingPacket(T))
#     if @pending_close
#       return
#     end

#     @send_queue.send(op)
#   end

#   def close
#     @pending_close = true
#   end

#   def close(op : OutgoingPacket(MMO::Client(T))?)
#     close({op})
#   end

#   def close(packets : Enumerable(OutgoingPacket(Client(T))?))
#     unless @pending_close
#       @pending_close = true
#       @send_queue.send(nil)
#       unless packets.empty?
#         debug { "Closing with packets: #{packets.map &.class}." }
#         packets.each { |op| @send_queue.send(op) if op }
#         @manager.close_connection(self)
#       end
#     end
#   end

#   def closed? : Bool
#     @pending_close
#   end

#   def send_queue(&block : Deque(OutgoingPacket(T)) ->)
#     @send_queue_mutex.synchronize { yield @send_queue }
#   end
# end
