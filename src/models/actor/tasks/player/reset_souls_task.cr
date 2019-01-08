struct ResetSoulsTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.clear_souls
  end
end
