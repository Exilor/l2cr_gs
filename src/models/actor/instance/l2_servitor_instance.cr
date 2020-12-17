require "../../../data/sql/summon_effects_table"

class L2ServitorInstance < L2Summon
  @consume_item_interval_remaining = 0
  @life_task : TaskScheduler::PeriodicTask?

  getter life_time = 0
  getter consume_item_interval = 0
  property exp_multiplier : Float32 = 0f32
  property life_time_remaining : Int32 = 0
  property reference_skill : Int32 = 0
  property! item_consume : ItemHolder?

  def initialize(template : L2NpcTemplate, owner : L2PcInstance)
    super
    self.show_summon_animation = true
  end

  def instance_type : InstanceType
    InstanceType::L2ServitorInstance
  end

  def on_spawn
    super
    @life_task ||= ThreadPoolManager.schedule_general_at_fixed_rate(self, 0, 5000)
  end

  def level : Int32
    if @template
      return template.level.to_i32
    end

    0
  end

  def item_consume_interval=(interval : Int32)
    @consume_item_interval = interval
    @consume_item_interval_remaining = interval
  end

  def life_time=(time : Int32)
    @life_time = time
    @life_time_remaining = time
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    @life_task.try &.cancel
    SummonTable.remove_servitor(owner)

    true
  end

  def do_pickup_item(target : L2Object)
    # no-op
  end

  def stop_skill_effects(removed : Bool, skill_id : Int32)
    super
    SummonEffectsTable.remove_servitor_effects(owner, reference_skill, skill_id)
  end

  def store_me
    return if @reference_skill == 0 || dead?

    if Config.restore_servitor_on_reconnect
      SummonTable.save_summon(self)
    end
  end

  def store_effect(store : Bool)
    return unless Config.summon_store_skill_cooltime
    return if owner.nil? || owner.in_olympiad_mode?

    SummonEffectsTable.clear_servitor_effects(owner, reference_skill)
    GameDB.servitor_skill_save.insert(self, store)
  end

  def restore_effects
    return if owner.in_olympiad_mode?
    GameDB.servitor_skill_save.load(self)
    SummonEffectsTable.apply_servitor_effects(self, owner, reference_skill)
  end

  def unsummon(owner : L2PcInstance)
    @life_task.try &.cancel

    super

    unless @restore_summon
      SummonTable.remove_servitor(owner)
    end
  end

  def destroy_item(*args)
    owner.destroy_item(*args)
  end

  def destroy_item_by_item_id(*args)
    owner.destroy_item_by_item_id(*args)
  end

  def attack_element : Int8
    owner.attack_element
  end

  def get_attack_element_value(attr_id : Int) : Int32
    owner.get_attack_element_value(attr_id)
  end

  def get_defense_element_value(attr_id : Int) : Int32
    owner.get_defense_element_value(attr_id)
  end

  def servitor? : Bool
    true
  end

  def get_m_atk(target : L2Character?, skill : Skill?) : Float64
    super + (owner.get_m_atk(target, skill) * (owner.get_servitor_share_bonus(Stats::MAGIC_ATTACK) - 1.0))
  end

  def get_m_def(target : L2Character?, skill : Skill?) : Float64
    super + (owner.get_m_def(target, skill) * (owner.get_servitor_share_bonus(Stats::MAGIC_DEFENCE) - 1.0))
  end

  def get_p_atk(target : L2Character?) : Float64
    super + (owner.get_p_atk(target) * (owner.get_servitor_share_bonus(Stats::POWER_ATTACK) - 1.0))
  end

  def get_p_def(target : L2Character?) : Float64
    super + (owner.get_p_def(target) * (owner.get_servitor_share_bonus(Stats::POWER_DEFENCE) - 1.0))
  end

  def m_atk_spd : Int32
    (super + (owner.m_atk_spd * (owner.get_servitor_share_bonus(Stats::MAGIC_ATTACK_SPEED) - 1.0))).to_i
  end

  def max_hp : Int32
    (super + (owner.max_hp * (owner.get_servitor_share_bonus(Stats::MAX_HP) - 1.0))).to_i
  end

  def max_mp : Int32
    (super + (owner.max_mp * (owner.get_servitor_share_bonus(Stats::MAX_MP) - 1.0))).to_i
  end

  def get_critical_hit(target : L2Character?, skill : Skill?) : Int32
    super + (owner.get_critical_hit(target, skill) * (owner.get_servitor_share_bonus(Stats::CRITICAL_RATE) - 1.0)).to_i
  end

  def p_atk_spd : Float64
    super + (owner.p_atk_spd * (owner.get_servitor_share_bonus(Stats::POWER_ATTACK_SPEED) - 1.0))
  end

  def max_recoverable_hp : Int32
    calc_stat(Stats::MAX_RECOVERABLE_HP, max_hp).to_i
  end

  def max_recoverable_mp : Int32
    calc_stat(Stats::MAX_RECOVERABLE_MP, max_mp).to_i
  end

  def call
    used_time = 5000 # should be more if in combat?
    @life_time_remaining &-= used_time
    if dead? || !visible?
      @life_task.try &.cancel
      return
    end

    if @life_time_remaining < 0
      send_packet(SystemMessageId::SERVITOR_PASSED_AWAY)
      unsummon(owner)
      return
    end

    if @consume_item_interval > 0
      @consume_item_interval_remaining &-= used_time
      if @consume_item_interval_remaining <= 0 && item_consume.count > 0
        if item_consume.id > 0 && alive?
          if destroy_item_by_item_id("Consume", item_consume.id, item_consume.count, self, false)
            sm = SystemMessage.summoned_mob_uses_s1
            sm.add_item_name(item_consume.id)
            send_packet(sm)
            @consume_item_interval_remaining = @consume_item_interval
          else
            send_packet(SystemMessageId::SERVITOR_DISAPPEARED_NOT_ENOUGH_ITEMS)
            unsummon(@owner)
          end
        end
      end
    end

    send_packet(SetSummonRemainTime.new(life_time, @life_time_remaining))
    update_effect_icons
  end

  def summon_type : Int32
    1
  end
end
