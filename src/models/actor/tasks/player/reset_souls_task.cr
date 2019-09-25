struct ResetSoulsTask
  initializer pc : L2PcInstance

  def call
    @pc.clear_souls
  end
end
