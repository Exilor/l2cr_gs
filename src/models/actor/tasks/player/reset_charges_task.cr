struct ResetChargesTask
  initializer pc : L2PcInstance

  def call
    @pc.clear_charges
  end
end
