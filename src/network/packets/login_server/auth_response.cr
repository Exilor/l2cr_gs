require "../login_server_packet"
require "../game_server/server_status"

class Packets::Incoming::AuthResponse < LoginServerPacket
  include Loggable

  @server_id = 0
  @server_name = ""

  private def read_impl
    @server_id = c
    @server_name = s
  end

  private def run_impl
    debug "server_id: #{@server_id}, server_name: #{@server_name}."

    ss = Outgoing::ServerStatus.new
    if Config.server_list_bracket
      ss.add(Outgoing::ServerStatus::SERVER_LIST_SQUARE_BRACKET, Outgoing::ServerStatus::ON)
    else
      ss.add(Outgoing::ServerStatus::SERVER_LIST_SQUARE_BRACKET, Outgoing::ServerStatus::OFF)
    end
    ss.add(Outgoing::ServerStatus::SERVER_TYPE, Config.server_list_type)
    if Config.server_gmonly
      ss.add(Outgoing::ServerStatus::SERVER_LIST_STATUS, Outgoing::ServerStatus::STATUS_GM_ONLY)
    else
      ss.add(Outgoing::ServerStatus::SERVER_LIST_STATUS, Outgoing::ServerStatus::STATUS_AUTO)
    end
    if Config.server_list_age == 15
      ss.add(Outgoing::ServerStatus::SERVER_AGE, Outgoing::ServerStatus::SERVER_AGE_15)
    elsif Config.server_list_age == 18
      ss.add(Outgoing::ServerStatus::SERVER_AGE, Outgoing::ServerStatus::SERVER_AGE_18)
    else
      ss.add(Outgoing::ServerStatus::SERVER_AGE, Outgoing::ServerStatus::SERVER_AGE_ALL)
    end

    LoginServerClient.server_name = @server_name

    client.send_packet(ss)

    info "Attached with LoginServer."
  end
end
