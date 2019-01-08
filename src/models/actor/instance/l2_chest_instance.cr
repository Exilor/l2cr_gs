class L2ChestInstance < L2MonsterInstance
  @special_drop = false

  def initialize(template : L2NpcTemplate)
    super
    self.no_rnd_walk = true
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

  def do_item_drop(template : L2NpcTemplate, last_attacker : L2Character?)
    id = template().id

    unless @special_drop
      case
      when id >= 18265 && id <= 18286
        id += 3536
      when id == 18287 || id == 18288
        id = 21671
      when id == 18289 || id == 18290
        id = 21694
      when id == 18291 || id == 18292
        id = 21717
      when id == 18293 || id == 18294
        id = 21740
      when id == 18295 || id == 18296
        id = 21763
      when id == 18297 || id == 18298
        id = 21786
      end
    end

    super(NpcData[id], last_attacker)
  end

  def movement_disabled? : Bool
    true
  end

  def has_random_animation? : Bool
    false
  end
end
