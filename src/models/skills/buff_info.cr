require "./buff_time_task"
require "../effects/effect_task_info"
require "../effects/effect_tick_task"

class BuffInfo
  include Synchronizable

  @tasks : Interfaces::Map(AbstractEffect, EffectTaskInfo)?

  getter period_start_ticks : Int32
  getter task : TaskScheduler::DelayedTask?
  getter effects = [] of AbstractEffect
  getter effector, effected, skill
  property abnormal_time : Int32
  property charges : Int32 = 0
  property? removed : Bool = false
  property? in_use : Bool = true

  def initialize(effector : L2Character, effected : L2Character, skill : Skill)
    @effector = effector
    @effected = effected
    @skill = skill
    @abnormal_time = Formulas.effect_abnormal_time(effector, effected, skill)
    @period_start_ticks = GameTimer.ticks
  end

  def add_effect(effect : AbstractEffect)
    @effects << effect
  end

  def add_task(effect : AbstractEffect, task : EffectTaskInfo)
    tasks = @tasks || sync do
      @tasks ||= Concurrent::Map(AbstractEffect, EffectTaskInfo).new
    end
    tasks[effect] = task
  end

  def get_effect_task(effect : AbstractEffect) : EffectTaskInfo?
    if tasks = @tasks
      tasks[effect]?
    end
  end

  def time : Int32
    @abnormal_time -
    ((GameTimer.ticks - @period_start_ticks) // GameTimer::TICKS_PER_SECOND)
  end

  def stop_all_effects(removed : Bool)
    @removed = removed
    if task = @task
      task.cancel unless task.cancelled?
    end

    finish_effects
  end

  def initialize_effects
    if effected.player? && !skill.passive?
      sm = Packets::Outgoing::SystemMessage.you_feel_s1_effect
      sm.add_skill_name(skill)
      effected.send_packet(sm)
    end

    @effects.each do |e|
      next if e.instant? || (effected.dead? && !skill.passive?)

      e.on_start(self)

      if e.ticks > 0
        effect_task = EffectTickTask.new(self, e)
        time = e.ticks &* Config.effect_tick_ratio
        scheduled_future = ThreadPoolManager.schedule_effect_at_fixed_rate(effect_task, time, time)
        add_task(e, EffectTaskInfo.new(effect_task, scheduled_future))
      end

      fncs = e.get_stat_funcs(effector, effected, skill)
      effected.add_stat_funcs(fncs)
    end

    add_abnormal_visual_effects

    if @abnormal_time > 0
      task = BuffTimeTask.new(self)
      # @task = ThreadPoolManager.schedule_effect_at_fixed_rate(task, 0, 1000)
      delay = Time.s_to_ms(@abnormal_time)
      @task = ThreadPoolManager.schedule_effect(task, delay)
    end
  end

  def on_tick(effect : AbstractEffect, tick_count : Int) # tick_count is unused
    continue_forever = false

    if @in_use
      continue_forever = effect.on_action_time(self)
    end

    if !continue_forever && skill.toggle?
      if task = get_effect_task(effect)
        task.scheduled_future.cancel
        effected.effect_list.stop_skill_effects(true, skill)
      end
    end
  end

  def finish_effects
    if tasks = @tasks
      tasks.each_value &.scheduled_future.cancel
    end

    remove_stats

    @effects.each do |e|
      unless e.instant?
        e.on_exit(self)
      end
    end

    remove_abnormal_visual_effects
    # This check is custom. Allocating a packet for something that doesn't have
    # a human player behind it is a waste of resources.
    if @effected.acting_player
      if !(@effected.summon? && !@effected.as(L2Summon).owner.has_summon?)
        if @skill.toggle?
          sm = Packets::Outgoing::SystemMessage.s1_has_been_aborted
        elsif removed?
          sm = Packets::Outgoing::SystemMessage.effect_s1_has_been_removed
        elsif !@skill.passive?
          sm = Packets::Outgoing::SystemMessage.s1_has_worn_off
        end

        if sm
          sm.add_skill_name(@skill)
          @effected.send_packet(sm)
        end
      end
    end

    if same?(effected.effect_list.short_buff)
      effected.effect_list.short_buff_status_update(nil)
    end
  end

  def add_abnormal_visual_effects
    updated = false

    if skill.has_abnormal_visual_effects?
      effected.start_abnormal_visual_effect(false, skill.abnormal_visual_effects)
      updated = true
    end

    if effected.player? && skill.has_abnormal_visual_effects_event?
      effected.start_abnormal_visual_effect(false, skill.abnormal_visual_effects_event)
      updated = true
    end

    if skill.has_abnormal_visual_effects_special?
      effected.start_abnormal_visual_effect(false, skill.abnormal_visual_effects_special)
      updated = true
    end

    if updated
      effected.update_abnormal_effect
    end
  end

  def remove_abnormal_visual_effects
    updated = false

    if skill.has_abnormal_visual_effects?
      effected.stop_abnormal_visual_effect(false, skill.abnormal_visual_effects)
      updated = true
    end

    if effected.player? && skill.has_abnormal_visual_effects_event?
      effected.stop_abnormal_visual_effect(false, skill.abnormal_visual_effects_event)
      updated = true
    end

    if skill.has_abnormal_visual_effects_special?
      effected.stop_abnormal_visual_effect(false, skill.abnormal_visual_effects_special)
      updated = true
    end

    if updated
      effected.update_abnormal_effect
    end
  end

  def add_stats
    @effects.each do |effect|
      funcs = effect.get_stat_funcs(effector, effected, skill)
      effected.add_stat_funcs(funcs)
    end
  end

  def remove_stats
    @effects.each { |e| effected.remove_stats_owner(e) }
    effected.remove_stats_owner(skill)
  end

  # Only called in AdminCommandHandler::AdminBuffs
  def get_tick_count(effect : AbstractEffect) : Int32
    if tasks = @tasks
      if effect_task_info = tasks[effect]?
        return effect_task_info.effect_task.tick_count
      end
    end

    0
  end
end
