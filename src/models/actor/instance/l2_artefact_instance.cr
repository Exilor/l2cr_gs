class L2ArtefactInstance < L2Npc
  def on_spawn
    super
    castle.register_artefact(self)
  end

  def instance_type : InstanceType
    InstanceType::L2ArtefactInstance
  end

  def auto_attackable?(attacker : L2Character) : Bool
    false
  end

  def can_be_attacked? : Bool
    false
  end

  def on_forced_attack(pc : L2PcInstance)
    pc.action_failed
  end

  def reduce_current_hp(*args)
    # no-op
  end
end
