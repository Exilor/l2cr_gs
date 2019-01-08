struct SitDownTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.paralyzed = false
  end
end
