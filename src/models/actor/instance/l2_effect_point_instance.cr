class L2EffectPointInstance < L2Npc
  @owner : L2PcInstance?

  def initialize(template : L2NpcTemplate, owner : L2Character?)
    super(template)

    self.invul = false
    if @owner = owner.try &.acting_player?
      self.instance_id = acting_player.instance_id
    end
  end

  def initialize(template : L2NpcTemplate)
    super
    raise "This constructor must not be called"
  end

  def instance_type
    InstanceType::L2EffectPointInstance
  end

  def acting_player?
    @owner
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    pc.action_failed
  end

  def on_action_shift(pc : L2PcInstance)
    pc.action_failed
  end
end
