class L2EffectPointInstance < L2Npc
  @owner : L2PcInstance?

  def initialize(template : L2NpcTemplate, owner : L2PcInstance)
    @owner = owner

    super(template)

    self.invul = false
    self.instance_id = owner.instance_id
  end

  def initialize(template : L2NpcTemplate)
    super
    raise "This constructor must not be called"
  end

  def instance_type : InstanceType
    InstanceType::L2EffectPointInstance
  end

  def acting_player : L2PcInstance?
    @owner
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    pc.action_failed
  end

  def on_action_shift(pc : L2PcInstance)
    pc.action_failed
  end
end
