struct InventoryEnableTask
  initializer pc: L2PcInstance

  def call
    @pc.inventory_blocking_status = false
  end
end
