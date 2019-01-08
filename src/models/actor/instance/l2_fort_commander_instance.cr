class L2FortCommanderInstance < L2DefenderInstance
  property? can_talk : Bool = true

  def instance_type
    InstanceType::L2FortCommanderInstance
  end

  def has_random_animation?
    false
  end
end
