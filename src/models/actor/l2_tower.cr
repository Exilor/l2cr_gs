class L2Tower < L2Npc
  def initialize(template : L2NpcTemplate)
    super
    self.invul = false
  end

  def can_be_attacked? : Bool
    return false unless castle = castle?
    castle.residence_id > 0 && castle.siege.in_progress?
  end

  def auto_attackable?(attacker : L2Character) : Bool
    return false unless attacker.is_a?(L2PcInstance)
    return false unless castle = castle?
    return false unless castle.residence_id > 0 && castle.siege.in_progress?
    castle.siege.attacker?(attacker.clan?)
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    unless can_target?(pc)
      return
    end

    if self != pc.target
      pc.target = self
    elsif interact
      if auto_attackable?(pc) && (pc.z - z).abs < 100
        if GeoData.can_see_target?(pc, self)
          pc.set_intention(AI::ATTACK, self)
        end
      end
    end

    pc.action_failed
  end

  def on_forced_attack(pc : L2PcInstance)
    on_action(pc)
  end
end
