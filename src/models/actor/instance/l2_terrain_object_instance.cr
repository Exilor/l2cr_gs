class L2TerrainObjectInstance < L2Npc
  def instance_type : InstanceType
    InstanceType::L2TerrainObjectInstance
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    pc.action_failed
  end

  def on_action_shift(pc : L2PcInstance, interact : Bool)
    if pc.gm?
      super
    else
      pc.action_failed
    end
  end
end
