class L2FestivalMonsterInstance < L2MonsterInstance
  property offering_bonus : Int32 = 1 # L2J: _bonusMultiplier

  def instance_type : InstanceType
    InstanceType::L2FestivalMonsterInstance
  end

  def auto_attackable?(attacker : L2Character) : Bool
    !attacker.is_a?(L2FestivalMonsterInstance)
  end

  def aggressive? : Bool
    true
  end

  def has_random_animation? : Bool
    false
  end

  def do_item_drop(killer : L2Character?)
    return unless killer.is_a?(L2PcInstance)
    return unless party = killer.party

    party_leader = party.leader
    offerings = party_leader.inventory.add_item("Sign", SevenSignsFestival::FESTIVAL_OFFERING_ID, @offering_bonus.to_i64, party_leader, self)
    unless offerings
      error { "Couldn't reward #{party_leader} with offerings." }
      return super
    end

    if offerings.count != @offering_bonus
      iu = InventoryUpdate.modified(offerings)
    else
      iu = InventoryUpdate.added(offerings)
    end
    party_leader.send_packet(iu)

    super
  end
end
