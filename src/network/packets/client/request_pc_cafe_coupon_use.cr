class Packets::Incoming::RequestPCCafeCouponUse < GameClientPacket
  @str = ""

  private def read_impl
    @str = s
  end

  private def run_impl
    debug @str
  end
end
