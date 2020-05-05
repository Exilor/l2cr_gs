class Packets::Incoming::AuthLogin < GameClientPacket
  @account = ""
  @pk_2, @pk_1, @lk_1, @lk_2 = 0, 0, 0, 0

  private def read_impl
    @account = s.downcase
    @pk_2, @pk_1, @lk_1, @lk_2 = d, d, d, d
  end

  private def run_impl
    if @account.empty? || !client.protocol_ok?
      client.close(nil)
      return
    end

    key = SessionKey.new(@lk_1, @lk_2, @pk_1, @pk_2)

    debug { "User: #{@account}." }
    debug { "SessionKey: #{key}." }

    unless client.account_name?
      if LoginServerClient.instance.add_game_server_login(@account, client)
        client.account_name = @account
        LoginServerClient.instance.add_waiting_client_and_send_request(@account, client, key)
      else
        client.close(nil)
      end
    end
  end
end
