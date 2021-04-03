class Packets::Incoming::RequestEx2ndPasswordReq < GameClientPacket
  @change_pass = 0
  @password = ""
  @new_password : String?

  private def read_impl
    @change_pass = c
    @password = s
    if @change_pass == 2
      @new_password = s
    end
  end

  private def run_impl
    return unless SecondaryAuthData.enabled?

    spa = client.secondary_auth

    if @change_pass == 0 || !spa.password_exist?
      ret = spa.save_password(@password)
    elsif @change_pass == 2 && spa.password_exist?
      ret = spa.change_password(@password, @new_password.not_nil!)
    end

    if ret
      client.send_packet(Ex2ndPasswordAck::SUCCESS)
    end
  end
end
