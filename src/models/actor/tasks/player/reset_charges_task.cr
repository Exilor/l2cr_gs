struct ResetChargesTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.clear_charges
  end
end
