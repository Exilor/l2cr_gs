require "../known_list/friendly_mob_known_list"

class L2FriendlyMobInstance < L2Attackable
  def instance_type : InstanceType
    InstanceType::L2FriendlyMobInstance
  end

  def init_known_list
    @known_list = FriendlyMobKnownList.new(self)
  end

  def known_list : FriendlyMobKnownList
    super.as(FriendlyMobKnownList)
  end

  def auto_attackable?(attacker : L2Character) : Bool
    if attacker.is_a?(L2PcInstance)
      return attacker.karma > 0
    end

    false
  end

  def aggressive? : Bool
    true
  end
end
