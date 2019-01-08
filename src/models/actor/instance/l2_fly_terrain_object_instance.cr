class L2FlyTerrainObjectInstance < L2Npc
  def initialize(template : L2NpcTemplate)
    super
    self.flying = true
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    pc.action_failed
  end

  def on_action_shift(pc : L2PcInstance)
    pc.gm? ? super : pc.action_failed
  end

  def instance_type
    InstanceType::L2FlyTerrainObjectInstance
  end
end
