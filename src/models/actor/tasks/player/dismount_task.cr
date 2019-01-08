struct DismountTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.dismount
  end
end
