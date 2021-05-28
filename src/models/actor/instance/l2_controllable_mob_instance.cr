require "../ai/l2_controllable_mob_ai"

class L2ControllableMobInstance < L2MonsterInstance
  def instance_type : InstanceType
    InstanceType::L2ControllableMobInstance
  end

  def aggro_range : Int32
    500
  end

  private def init_ai : L2CharacterAI
    L2ControllableMobAI.new(self)
  end

  def do_die(killer : L2Character?) : Bool
    unless super
      return false
    end

    self.ai = nil

    true
  end

  def detach_ai
    # no-op
  end
end
