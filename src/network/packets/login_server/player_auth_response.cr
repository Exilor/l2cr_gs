require "../login_server_packet"
require "../game_server/player_in_game"
require "../server/char_selection_info"

class Packets::Incoming::PlayerAuthResponse < LoginServerPacket
  include Loggable

  @account = ""
  @authed = false

  private def read_impl
    @account = s
    @authed = c == 1
  end

  private def run_impl
    wc = LoginServerClient.waiting_clients.find { |c| c.account == @account }
    if wc
      if @authed
        client.send_packet(Packets::Outgoing::PlayerInGame.new(@account))

        wc.client.state = GameClient::State::AUTHED
        wc.client.session_id = wc.session_key

        csi = Packets::Outgoing::CharSelectionInfo.new(wc.account, wc.session_key.play_ok_1)
        wc.client.send_packet(csi)

        wc.client.char_selection = csi.char_info
      else
        LoginServerClient.accounts.delete(wc.account)
        warn "SessionKey is not correct."
      end
      LoginServerClient.waiting_clients.delete_first(wc)
    else
      warn { "Didn't find waiting client for account \"#{@account}\"." }
    end
  end
end
