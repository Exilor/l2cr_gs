class Packets::Incoming::RequestEx2ndPasswordVerify < GameClientPacket
  @password = ""

  private def read_impl
    @password = s
  end

  private def run_impl
    return unless SecondaryAuthData.enabled?
    client.secondary_auth.check_password(@password, false)
  end
end
