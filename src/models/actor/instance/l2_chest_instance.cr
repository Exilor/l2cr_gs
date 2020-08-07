class L2ChestInstance < L2MonsterInstance
  @special_drop = false

  def initialize(template : L2NpcTemplate)
    super
    self.no_random_walk = true
  end

  def instance_type : InstanceType
    InstanceType::L2ChestInstance
  end

  def set_special_drop
    @special_drop = true
  end

  def on_spawn
    super

    @special_drop = false
    @must_reward_exp_sp = true
  end

  def do_item_drop(template : L2NpcTemplate, killer : L2Character?)
    id = template().id

    unless @special_drop
      case id
      when 18265..18286
        id &+= 3536
      when 18287, 18288
        id = 21671
      when 18289, 18290
        id = 21694
      when 18291, 18292
        id = 21717
      when 18293, 18294
        id = 21740
      when 18295, 18296
        id = 21763
      when 18297, 18298
        id = 21786
      end
    end

    super(NpcData[id], killer)
  end

  def movement_disabled? : Bool
    true
  end

  def has_random_animation? : Bool
    false
  end
end
