class L2QuestGuardInstance < L2GuardInstance
  setter auto_attackable : Bool = true
  property? passive : Bool = false

  def instance_type
    InstanceType::L2QuestGuardInstance
  end

  def auto_attackable?(attacker : L2Character) : Bool
    @auto_attackable && !attacker.is_a?(L2PcInstance)
  end

  def add_damage(attacker : L2Character, damage : Int32, skill : Skill?)
    super

    if attacker.is_a?(L2Attackable)
      # This uninitialized player is necessary because using nil like L2J does
      # would complicate all other code involving this EventType.
      fake_player = uninitialized L2PcInstance
      OnAttackableAttack.new(fake_player, self, damage, skill, false).async(self)
    end
  end

  def do_die(killer : L2Character?) : Bool
    unless super
      return false
    end

    if killer.is_a?(L2Attackable)
      # This uninitialized player is necessary because using nil like L2J does
      # would complicate all other code involving this EventType.
      fake_player = uninitialized L2PcInstance
      OnAttackableKill.new(fake_player, self, false).delayed(self, @on_kill_delay.to_i64)
    end

    true
  end

  def add_damage_hate(attacker : L2Character?, damage : Int32, aggro : Int64)
    if !@passive && !attacker.is_a?(L2PcInstance)
      super
    end
  end

  def auto_attackable?(attacker : L2Character) : Bool
    @auto_attackable && !attacker.is_a?(L2PcInstance)
  end
end
