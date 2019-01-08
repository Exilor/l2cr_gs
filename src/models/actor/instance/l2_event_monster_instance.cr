class L2EventMonsterInstance < L2MonsterInstance
  property? block_skill_attack : Bool = false
  property? drop_on_ground : Bool = false

  def instance_type
    InstanceType::L2EventMobInstance
  end
end
