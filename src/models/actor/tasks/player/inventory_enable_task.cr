struct InventoryEnableTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.inventory_blocking_status = false
  end
end
