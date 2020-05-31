class L2QuestGuardInstance < L2GuardInstance
  setter auto_attackable : Bool = true
  property? passive : Bool = false

  def instance_type : InstanceType
    InstanceType::L2QuestGuardInstance
  end

  def auto_attackable?(attacker : L2Character) : Bool
    @auto_attackable && !attacker.is_a?(L2PcInstance)
  end

  def add_damage(attacker : L2Character, damage : Int32, skill : Skill?)
    super

    if attacker.is_a?(L2Attackable)
      OnAttackableAttack.new(nil, self, damage, skill, false).async(self)
    end
  end

  def do_die(killer : L2Character?) : Bool
    unless super
      return false
    end

    if killer.is_a?(L2Attackable)
      OnAttackableKill.new(nil, self, false).delayed(self, @on_kill_delay.to_i64)
    end

    true
  end

  def add_damage_hate(attacker : L2Character?, damage : Int, aggro : Int)
    if !@passive && !attacker.is_a?(L2PcInstance)
      super
    end
  end

  def auto_attackable?(attacker : L2Character) : Bool
    @auto_attackable && !attacker.is_a?(L2PcInstance)
  end
end
