struct TeleportWatchdogTask
  initializer pc: L2PcInstance

  def call
    if @pc.teleporting?
      @pc.on_teleported
    end
  end
end
