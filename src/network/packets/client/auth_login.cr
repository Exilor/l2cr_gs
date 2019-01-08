class Packets::Incoming::AuthLogin < GameClientPacket
  @account = ""
  @pk_2, @pk_1, @lk_1, @lk_2 = 0, 0, 0, 0

  def read_impl
    @account = s.downcase
    @pk_2, @pk_1, @lk_1, @lk_2 = d, d, d, d
  end

  def run_impl
    if @account.empty? || !client.protocol_ok?
      client.close
      return
    end

    key = SessionKey.new(@lk_1, @lk_2, @pk_1, @pk_2)

    if Config.debug
      debug "User: #{@account.inspect}."
      debug "SessionKey: #{key.inspect}."
    end

    if client.account_name?
      client.close
      return
    end

    if LoginServerClient.add_game_server_login(@account, client)
      client.account_name = @account
      LoginServerClient.add_waiting_client_and_send_request(@account, client, key)
    else
      client.close
    end
  end
end
