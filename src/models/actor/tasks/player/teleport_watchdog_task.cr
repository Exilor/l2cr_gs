struct TeleportWatchdogTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    if @pc.teleporting?
      @pc.on_teleported
    end
  end
end
