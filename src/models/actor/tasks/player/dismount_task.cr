struct DismountTask
  initializer pc : L2PcInstance

  def call
    @pc.dismount
  end
end
