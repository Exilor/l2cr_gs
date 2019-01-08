require "../ai/l2_controllable_mob_ai"

class L2ControllableMobInstance < L2MonsterInstance
  property? invul : Bool = false

  def instance_type
    InstanceType::L2ControllableMobInstance
  end

  def aggro_range
    500
  end

  def init_ai
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

  # TODO
end
