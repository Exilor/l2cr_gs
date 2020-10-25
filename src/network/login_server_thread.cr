class LoginServerThread
  include Singleton
  include Cancellable
  include Loggable
  include Packets::Outgoing

  private record WaitingClient, account : String, client : GameClient,
    session_key : SessionKey

  private WAITING = Concurrent::Array(WaitingClient).new
  private ACCOUNTS = Concurrent::Map(String, GameClient).new

  private IN_BUFFER = ByteBuffer.new
  private OUT_BUFFER = ByteBuffer.new

  getter port = 0
  getter game_port = 0
  getter host = ""
  getter game_host = ""
  getter hex_id = Bytes.empty
  getter request_id = 1
  getter accept_alternate = true
  getter max_players = 0
  getter status = 0
  getter reserve_host = false
  property server_name : String = ""
  private getter! crypt : NewCrypt
  private getter! socket : TCPSocket

  def initialize
    @port = Config.game_server_login_port
    @game_port = Config.port_game
    @host = Config.game_server_login_host == "*" ? "127.0.0.1" : Config.game_server_login_host
    @host = @host == "*" ? "127.0.0.1" : Socket::IPAddress.new(@host, @port).address
    @game_host = Config.gameserver_hostname == "*" ? "127.0.0.1" : Config.gameserver_hostname
    @game_host = @game_host == "*" ? "127.0.0.1" : Socket::IPAddress.new(@game_host, @game_port).address
    @max_players = Config.maximum_online_users
    @hex_id = Config.hex_id
    if @hex_id.empty?
      @hex_id = Rnd.bytes(16)
      @request_id = Config.request_id
    else
      @request_id = Config.server_id
    end

    @accept_alternate = Config.accept_alternate_id
    @reserve_host = Config.reserve_host_on_login
    # @subnets = Config.game_server_subnets
    # @hosts = Config.game_server_hosts

    IN_BUFFER.set_encoding("UTF-16LE")
    OUT_BUFFER.set_encoding("UTF-16LE")

    spawn do
      until cancelled?
        read_loop
        sleep(2)
      end
    end
  end

  def terminate
    cancel
    socket?.try &.close
  end

  private def read_loop
    info { "Trying to connect to LoginServer at #{@host}:#{@port}" }
    @socket = TCPSocket.new(@host, @port)
    @crypt = NewCrypt.new("_;v.]05-31!|+-%xT!^[$\00".bytes)
    until cancelled?
      IN_BUFFER.clear

      size = (socket.read_bytes(UInt16) - 2).to_i32
      unless IO.copy(socket, IN_BUFFER, size) == size
        warn "Incomplete packet received from LoginServer, closing connection."
        break
      end

      crypt.decrypt(IN_BUFFER.slice, 0, size)
      checksum_ok = NewCrypt.verify_checksum(IN_BUFFER.slice, 0, size)

      unless checksum_ok
        warn "wrong checksum"
      end

      IN_BUFFER.rewind
      opcode = IN_BUFFER.read_bytes(UInt8)
      packet = case opcode
      when 0x00 then Packets::Incoming::InitLS.new
      when 0x01 then Packets::Incoming::LoginServerFail.new
      when 0x02 then Packets::Incoming::AuthResponse.new
      when 0x03 then Packets::Incoming::PlayerAuthResponse.new
      when 0x04 then Packets::Incoming::KickPlayer.new
      when 0x05 then Packets::Incoming::RequestCharacters.new
      when 0x06 then Packets::Incoming::ChangePasswordResponse.new
      else
        warn { "Unknown opcode: 0x#{opcode.to_s(16)}." }
      end

      if packet
        packet.client = self
        packet.buffer = IN_BUFFER
        packet.read
        packet.run
      end
    end
  rescue IO::EOFError
    warn "Disconnected from LoginServer."
  rescue e : IO::Error
    error e.message
  rescue e
    unless cancelled?
      error e
    end
  ensure
    @socket.try &.close
  end

  def send_packet(packet : MMO::OutgoingPacket(self))
    {% if flag?(:preview_mt) %} debug { "send_packet start: #{packet}" } {% end %}
    return if cancelled?

    OUT_BUFFER.clear
    OUT_BUFFER.pos = 2
    packet.buffer = OUT_BUFFER
    packet.write

    size = OUT_BUFFER.pos - 2
    OUT_BUFFER.write_bytes(0)
    until (OUT_BUFFER.pos - 2) % 8 == 0
      OUT_BUFFER.write_bytes(0u8)
    end
    NewCrypt.append_checksum(OUT_BUFFER.slice, 2, OUT_BUFFER.pos)
    crypt.encrypt(OUT_BUFFER.slice, 2, OUT_BUFFER.pos)

    OUT_BUFFER.rewind
    remaining = OUT_BUFFER.remaining
    OUT_BUFFER.write_bytes(remaining.to_u16)

    socket.write(OUT_BUFFER.to_slice)

    {% if flag?(:preview_mt) %} debug { "send_packet end: #{packet}" } {% end %}
  rescue e : IO::Error
    error e
  end

  def waiting_clients : Interfaces::Array(WaitingClient)
    WAITING
  end

  def accounts : Interfaces::Map(String, GameClient)
    ACCOUNTS
  end

  def add_game_server_login(account : String, client : GameClient) : Bool
    if ACCOUNTS.has_key?(account)
      error { "Account '#{account}' already present in ACCOUNTS." }
      return false
    end

    ACCOUNTS[account] = client
    true
  end

  def add_waiting_client_and_send_request(account : String, client : GameClient, key : SessionKey)
    WAITING << WaitingClient.new(account, client, key)
    send_packet(PlayerAuthRequest.new(account, key))
  end

  def send_logout(account : String?)
    return unless account

    debug { "Sending PlayerLogout for '#{account}' to LoginServer." }
    begin
      send_packet(PlayerLogout.new(account))
    rescue e
      error e
    ensure
      ACCOUNTS.delete(account)
    end
  end

  def max_players=(max_players : Int32)
    @max_players = max_players
    send_server_status(ServerStatus::MAX_PLAYERS, max_players)
  end

  def server_status=(status)
    case status
    when ServerStatus::STATUS_AUTO..ServerStatus::STATUS_GM_ONLY
      send_server_status(ServerStatus::SERVER_LIST_STATUS, status)
      @status = status
    else
      raise ArgumentError.new("Wrong status #{status}")
    end
  end

  def send_server_status(id : Int32, value : Int32)
    ss = ServerStatus.new
    ss.add(id, value)
    begin
      send_packet(ss)
    rescue e
      error e
    end
  end

  def send_server_type
    ss = ServerStatus.new
    ss.add(ServerStatus::SERVER_TYPE, Config.server_list_type)
    begin
      send_packet(ss)
    rescue e
      error e
    end
  end

  def send_change_password(account : String, char_name : String, old_pass : String, new_pass : String)
    send_packet(ChangePassword.new(account, char_name, old_pass, new_pass))
  rescue e
    error e
  end

  def server_status=(status : Int32)
    case status
    when ServerStatus::STATUS_AUTO
      send_server_status(ServerStatus::SERVER_LIST_STATUS, ServerStatus::STATUS_AUTO)
      @status = status
    when ServerStatus::STATUS_DOWN
      send_server_status(ServerStatus::SERVER_LIST_STATUS, ServerStatus::STATUS_DOWN)
      @status = status
    when ServerStatus::STATUS_FULL
      send_server_status(ServerStatus::SERVER_LIST_STATUS, ServerStatus::STATUS_FULL)
      @status = status
    when ServerStatus::STATUS_GM_ONLY
      send_server_status(ServerStatus::SERVER_LIST_STATUS, ServerStatus::STATUS_GM_ONLY)
      @status = status
    when ServerStatus::STATUS_GOOD
      send_server_status(ServerStatus::SERVER_LIST_STATUS, ServerStatus::STATUS_GOOD)
      @status = status
    when ServerStatus::STATUS_NORMAL
      send_server_status(ServerStatus::SERVER_LIST_STATUS, ServerStatus::STATUS_NORMAL)
      @status = status
    else
      raise ArgumentError.new("Server status #{status} does not exist")
    end
  end

  def get_chars_on_server(account : String)
    chars = 0
    to_delete = [] of Int64
    sql = "SELECT deletetime FROM characters WHERE account_name=?"
    GameDB.each(sql, account) do |rs|
      chars &+= 1
      del_time = rs.get_i64(:"deletetime")
      if del_time != 0
        to_delete << del_time
      end
    end

    rec = ReplyCharacters.new(account, chars, to_delete)
    send_packet(rec)
  rescue e
    error e
  end

  def send_access_level(account : String, level : Int32)
    cal = ChangeAccessLevel.new(account, level)
    send_packet(cal)
  rescue e
    error e
  end

  def do_kick_player(account : String)
    if client = ACCOUNTS[account]?
      warn { "#{client} kicked out by LoginServer." }
      client.additional_close_packet = SystemMessage.another_login_with_account
      client.close_now
    end
  end

  def status_string : String
    ServerStatus::STATUS_STRING[@status]
  end

  def get_client(name : String) : GameClient?
    ACCOUNTS[name]?
  end
end

require "./packets/login_server/*"
require "./packets/game_server/*"
