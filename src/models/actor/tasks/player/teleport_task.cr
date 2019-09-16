struct TeleportTask
  initializer pc: L2PcInstance, loc: Location

  def call
    if @pc.online?
      @pc.tele_to_location(@loc, true)
    end
  end
end
