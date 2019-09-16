struct SitDownTask
  initializer pc: L2PcInstance

  def call
    @pc.paralyzed = false
  end
end
