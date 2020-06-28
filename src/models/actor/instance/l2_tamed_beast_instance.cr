require "./l2_feedable_beast_instance"

class L2TamedBeastInstance < L2FeedableBeastInstance
  private MAX_DISTANCE_FROM_HOME = 30000
  private MAX_DISTANCE_FROM_OWNER = 2000
  private MAX_DURATION = 1200000 # 20 minutes
  private DURATION_CHECK_INTERVAL = 60000 # 1 minute
  private DURATION_INCREASE_INTERVAL = 20000 # 20 secs (gained upon feeding)
  private BUFF_INTERVAL = 5000 # 5 seconds

  @home_x = 0
  @home_y = 0
  @home_z = 0
  @buff_task : TaskScheduler::PeriodicTask?
  @duration_check_task : TaskScheduler::PeriodicTask?
  @beast_skills : Interfaces::Array(Skill)?

  getter food_type = 0
  getter! owner : L2PcInstance
  getter? freya_beast = false
  property remaining_time : Int32 = MAX_DURATION

  # Required for Crystal
  def initialize(template : L2NpcTemplate)
    super
  end

  def initialize(template_id : Int32)
    super(NpcData[template_id])
    set_home(self)
  end

  def initialize(template_id : Int32, owner : L2PcInstance, food_skill_id : Int32, x : Int32, y : Int32, z : Int32)
    super(NpcData[template_id])

    @freya_beast = false
    heal!
    self.owner = owner
    self.food_type = food_skill_id
    set_home(x, y, z)
    spawn_me(x, y, z)
  end

  def initialize(template_id : Int32, owner : L2PcInstance, food : Int32, x : Int32, y : Int32, z : Int32, freya_beast : Bool)
    super(NpcData[template_id])

    @freya_beast = freya_beast
    heal!
    self.food_type = food
    set_home(x, y, z)
    spawn_me(x, y, z)
    self.owner = owner
    if freya_beast
      set_intention(AI::FOLLOW, @owner)
    end
  end

  def instance_type : InstanceType
    InstanceType::L2TamedBeastInstance
  end

  def on_receive_food
    # Eating food < the duration by 20secs, to a max of 20minutes
    @remaining_time = @remaining_time + DURATION_INCREASE_INTERVAL
    if @remaining_time > MAX_DURATION
      @remaining_time = MAX_DURATION
    end
  end

  def home
    Location.new(@home_x, @home_y, @home_z)
  end

  def set_home(x : Int32, y : Int32, z : Int32)
    @home_x = x
    @home_y = y
    @home_z = z
  end

  def set_home(c : L2Character)
    set_home(*c.xyz)
  end

  def food_type=(food_item_id : Int32)
    if food_item_id > 0
      @food_type = food_item_id

      # start the duration checks
      # start the buff tasks
      if task = @duration_check_task
        task.cancel
      end
      @duration_check_task = ThreadPoolManager.schedule_general_at_fixed_rate(CheckDuration.new(self), DURATION_CHECK_INTERVAL, DURATION_CHECK_INTERVAL)
    end
  end

  def do_die(killer : L2Character?) : Bool
    unless super
      return false
    end

    ai.stop_follow
    if task = @buff_task
      task.cancel
    end
    if task = @duration_check_task
      task.cancel
    end

    if owner = @owner
      owner.remove_tamed_beast(self)
    end
    @buff_task = nil
    @duration_check_task = nil
    @owner = nil
    @food_type = 0
    @remaining_time = 0

    true
  end

  def auto_attackable?(attacker : L2Character) : Bool
    !@freya_beast
  end

  def add_beast_skill(skill : Skill)
    (@beast_skills ||= Concurrent::Array(Skill).new) << skill
  end

  def cast_beast_skills
    unless @owner
      return
    end

    unless skills = @beast_skills
      return
    end

    delay = 100
    beast_skills.each do |skill|
      ThreadPoolManager.schedule_general(BuffCast.new(self, skill), delay)
      delay += (100 + skill.hit_time)
    end
    ThreadPoolManager.schedule_general(BuffCast.new(self, nil), delay)
  end

  private struct BuffCast
    initializer beast : L2TamedBeastInstance, skill : Skill?

    def call
      if skill = @skill
        @beast.sit_cast_and_follow(skill, @beast.owner)
      else
        @beast.set_intention(AI::FOLLOW, @beast.owner)
      end
    end
  end

  def owner=(owner : L2PcInstance?)
    if owner
      @owner = owner
      self.title = owner.name
      # broadcast the new title
      self.show_summon_animation = true
      broadcast_packet(NpcInfo.new(self, owner))

      owner.add_tamed_beast(self)

      # always and automatically follow the owner.
      ai.start_follow(owner, 100)

      unless @freya_beast
        # instead of calculating this value each time, let's get this now and pass it on
        total_buffs_available = 0
        template.skills.each_value do |skill|
          # if the skill is a buff, check if the owner has it already [ owner.getEffect(L2Skill skill) ]
          if skill.continuous? && !skill.debuff?
            total_buffs_available += 1
          end
        end

        # start the buff tasks
        if task = @buff_task
          task.cancel
        end
        @buff_task = ThreadPoolManager.schedule_general_at_fixed_rate(CheckOwnerBuffs.new(self, total_buffs_available), BUFF_INTERVAL, BUFF_INTERVAL)
      end
    else
      delete_me # despawn if no owner
    end
  end

  def too_far_from_home? : Bool
    !inside_radius?(@home_x, @home_y, @home_z, MAX_DISTANCE_FROM_HOME, true, true)
  end

  def delete_me
    if task = @buff_task
      task.cancel
    end
    if task = @duration_check_task
      task.cancel
    end
    stop_hp_mp_regeneration

    if owner = @owner
      owner.remove_tamed_beast(self)
    end
    self.target = nil
    @buff_task = nil
    @duration_check_task = nil
    @owner = nil
    @food_type = 0
    @remaining_time = 0

    # remove the spawn
    super
  end

  # notification triggered by the owner when the owner is attacked.
  # tamed mobs will heal/recharge or debuff the enemy according to their skills
  def on_owner_got_attacked(attacker : L2Character?)
    # check if the owner is no longer around...if so, despawn
    owner = @owner

    if owner.nil? || !owner.online?
      delete_me
      return
    end
    # if the owner is too far away, stop anything else and immediately run towards the owner.
    unless owner.inside_radius?(self, MAX_DISTANCE_FROM_OWNER, true, true)
      ai.start_follow(owner)
      return
    end
    # if the owner is dead, do nothing...
    if owner.dead? || @freya_beast
      return
    end

    # if the tamed beast is currently in the middle of casting, let it complete its skill...
    if casting_now?
      return
    end

    hp_ratio = owner.current_hp / owner.max_hp

    # if the owner has a lot of HP, then debuff the enemy with a random debuff among the available skills
    # use of more than one debuff at this moment is acceptable
    if hp_ratio >= 0.8
      template.skills.each_value do |skill|
        # if the skill is a debuff, check if the attacker has it already [ attacker.getEffect(L2Skill skill) ]
        if skill.debuff? && Rnd.rand(3) < 1 && attacker
          if attacker.affected_by_skill?(skill.id)
            sit_cast_and_follow(skill, attacker)
          end
        end
      end
    # for HP levels between 80% and 50%, do not react to attack events (so that MP can regenerate a bit)
    # for lower HP ranges, heal or recharge the owner with 1 skill use per attack.
    elsif hp_ratio < 0.5
      chance = 1
      if hp_ratio < 0.25
        chance = 2
      end

      # if the owner has a lot of HP, then debuff the enemy with a random debuff among the available skills
      template.skills.each_value do |skill|
        # if the skill is a buff, check if the owner has it already [ owner.getEffect(L2Skill skill) ]
        if Rnd.rand(5) < chance
          if skill.has_effect_type?(EffectType::CP, EffectType::HP, EffectType::MANAHEAL_BY_LEVEL, EffectType::MANAHEAL_PERCENT)
            sit_cast_and_follow(skill, owner)
          end
        end
      end
    end
  end

  # /**
  #  * Prepare and cast a skill:<br>
  #  * First smoothly prepare the beast for casting, by abandoning other actions.<br>
  #  * Next, call super.do_cast(skill) in order to actually cast the spell.<br>
  #  * Finally, return to auto-following the owner.
  #  * @param skill
  #  * @param target
  #  */
  protected def sit_cast_and_follow(skill : Skill, target : L2Character)
    stop_move(nil)
    broadcast_packet(StopMove.new(self))
    self.intention = AI::IDLE

    self.target = target
    do_cast(skill)
    set_intention(AI::FOLLOW, @owner)
  end

  private struct CheckDuration
    initializer beast : L2TamedBeastInstance

    def call
      food_type_skill_id = @beast.food_type
      owner = @beast.owner

      item = nil
      if @beast.freya_beast?
        item = owner.inventory.get_item_by_item_id(food_type_skill_id)
        if item && item.count >= 1
          owner.destroy_item("BeastMob", item, 1, @beast, true)
          @beast.broadcast_packet(SocialAction.new(@beast.l2id, 3))
        else
          @beast.delete_me
        end
      else
        @beast.remaining_time = @beast.remaining_time - DURATION_CHECK_INTERVAL
        # I tried to avoid this as much as possible...but it seems I can't avoid hardcoding
        # ids further, except by carrying an additional variable just for these two lines...
        # Find which food item needs to be consumed.
        if food_type_skill_id == 2188
          item = owner.inventory.get_item_by_item_id(6643)
        elsif food_type_skill_id == 2189
          item = owner.inventory.get_item_by_item_id(6644)
        end

        # if the owner has enough food, call the item handler (use the food and triffer all necessary actions)
        if item && item.count >= 1
          old_target = owner.target
          owner.target = @beast
          targets = [@beast] of L2Object

          # emulate a call to the owner using food, but bypass all checks for range, etc
          # this also causes a call to the AI tasks handling feeding, which may call on_receive_food as required.
          owner.call_skill(SkillData[food_type_skill_id, 1], targets)
          owner.target = old_target
        else
          # if the owner has no food, the beast immediately despawns, except when it was only
          # newly spawned. Newly spawned beasts can last up to 5 minutes
          if @beast.remaining_time < MAX_DURATION - 300000
            @beast.remaining_time = -1
          end
        end
        # There are too many conflicting reports about whether distance from home should be taken into consideration. Disabled for now.
        # if @beast.too_far_from_home?)
        # @beast.remaining_time = -1

        if @beast.remaining_time <= 0
          @beast.delete_me
        end
      end
    end
  end

  private struct CheckOwnerBuffs
    initializer beast : L2TamedBeastInstance, num_buffs : Int32

    def call
      owner = @beast.owner?

      # check if the owner is no longer around...if so, despawn
      if owner.nil? || !owner.online?
        @beast.delete_me
        return
      end
      # if the owner is too far away, stop anything else and immediately run towards the owner.
      unless @beast.inside_radius?(owner, MAX_DISTANCE_FROM_OWNER, true, true)
        @beast.ai.start_follow(owner)
        return
      end
      # if the owner is dead, do nothing...
      if owner.dead?
        return
      end
      # if the tamed beast is currently casting a spell, do not interfere (do not attempt to cast anything new yet).
      if @beast.casting_now?
        return
      end

      total_buffs_on_owner = 0
      i = 0
      rnd = Rnd.rand(@num_buffs)
      buffs_to_give = nil

      # get this npc's skills: getSkills
      @beast.template.skills.each_value do |skill|
        # if the skill is a buff, check if the owner has it already [ owner.getEffect(L2Skill skill) ]
        if skill.continuous? && !skill.debuff?
          i &+= 1
          if i == rnd
            buffs_to_give = skill
          end
          if owner.affected_by_skill?(skill.id)
            total_buffs_on_owner += 1
          end
        end
      end
      # if the owner has less than 60% of this beast's available buff, cast a random buff
      if (@num_buffs &* 2) // 3 > total_buffs_on_owner
        @beast.sit_cast_and_follow(buffs_to_give.not_nil!, owner)
      end
      @beast.set_intention(AI::FOLLOW, @beast.owner)
    end
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    if pc.nil? || !can_target?(pc)
      return
    end

    # Check if the L2PcInstance already target the L2NpcInstance
    if self != pc.target
      # Set the target of the pc
      pc.target = self
    elsif interact
      if auto_attackable?(pc) && (pc.z - z).abs < 100
        pc.ai.set_intention(AI::ATTACK, self)
      else
        # Send a Server->Client ActionFailed to the L2PcInstance in order to avoid that the client wait another packet
        pc.action_failed
      end
    end
  end
end
