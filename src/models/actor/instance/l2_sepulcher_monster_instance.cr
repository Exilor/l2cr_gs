class L2SepulcherMonsterInstance < L2MonsterInstance
  private FAKE_PETRIFICATION = SkillHolder.new(4616)

  @victim_spawn_key_box_task : Scheduler::DelayedTask?
  @victim_shout : Scheduler::DelayedTask?
  @change_immortal_task : Scheduler::DelayedTask?
  @on_dead_event_task : Scheduler::DelayedTask?

  property mysterious_box_id : Int32 = 0

  def initialize(template : L2NpcTemplate)
    super

    self.show_summon_animation = true
    case template.id
    when 25339, 25342, 25346, 25349
      self.raid = true
    else
      # [automatically added else]
    end

  end

  def instance_type : InstanceType
    InstanceType::L2SepulcherMonsterInstance
  end

  def on_spawn
    self.show_summon_animation = false

    case id
    when 18150..18157
      if task = @victim_spawn_key_box_task
        task.cancel
      end
      task = VictimSpawnKeyBox.new(self)
      @victim_spawn_key_box_task = ThreadPoolManager.schedule_effect(task, 300_000)
      if task = @victim_shout
        task.cancel
      end
      @victim_shout = ThreadPoolManager.schedule_effect(VictimShout.new(self), 5000)
    when 18196..18211
      # nothing
    when 18231..18243
      if task = @change_immortal_task
        task.cancel
      end
      @change_immortal_task = ThreadPoolManager.schedule_effect(ChangeImmortal.new(self), 1600)
    when 18256
      # nothing
    when 25339, 25342, 25346, 25349
      self.raid = true
    else
      # [automatically added else]
    end


    super
  end

  def do_die(killer : L2Character?) : Bool
    unless super
      return false
    end

    case id
    when 18120..18131, 18149, 18158..18165, 18183, 18184, 18212..18219
      if task = @on_dead_event_task
        task.cancel
      end
      @on_dead_event_task = ThreadPoolManager.schedule_effect(OnDeadEvent.new(self), 3500)
    when 18150..18157
      if task = @victim_spawn_key_box_task
        task.cancel
        @victim_spawn_key_box_task = nil
      end
      if task = @victim_shout
        task.cancel
        @victim_shout = nil
      end
      if task = @on_dead_event_task
        task.cancel
      end
      @on_dead_event_task = ThreadPoolManager.schedule_effect(OnDeadEvent.new(self), 3500)
    when 18141..18148
      if FourSepulchersManager.viscount_mobs_annihilated?(mysterious_box_id)
        if task = @on_dead_event_task
          task.cancel
        end
        @on_dead_event_task = ThreadPoolManager.schedule_effect(OnDeadEvent.new(self), 3500)
      end
    when 18220..18240
      if FourSepulchersManager.duke_mobs_annihilated?(mysterious_box_id)
        if task = @on_dead_event_task
          task.cancel
        end
        @on_dead_event_task = ThreadPoolManager.schedule_effect(OnDeadEvent.new(self), 3500)
      end
    when 25339, 25342, 25346, 25349
      if task = @on_dead_event_task
        task.cancel
      end
      @on_dead_event_task = ThreadPoolManager.schedule_effect(OnDeadEvent.new(self), 8500)
    else
      # [automatically added else]
    end


    true
  end

  def delete_me : Bool
    if task = @victim_spawn_key_box_task
      task.cancel
      @victim_spawn_key_box_task = nil
    end

    if task = @on_dead_event_task
      task.cancel
      @on_dead_event_task = nil
    end

    super
  end

  def auto_attackable?(attacker : L2Character) : Bool
    true
  end

  private struct VictimShout
    initializer mob : L2SepulcherMonsterInstance

    def call
      if @mob.dead?
        return
      end

      unless @mob.visible?
        return
      end

      @mob.broadcast_packet(NpcSay.new(@mob.l2id, 0, @mob.id, "forgive me!!"))
    end
  end

  private struct VictimSpawnKeyBox
    initializer mob : L2SepulcherMonsterInstance

    def call
      if @mob.dead?
        return
      end

      unless @mob.visible?
        return
      end

      FourSepulchersManager.spawn_key_box(@mob)

      @mob.broadcast_packet(NpcSay.new(@mob.l2id, 0, @mob.id, "Many thanks for rescue me."))
      if task = @mob.@victim_shout
        task.cancel
      end
    end
  end

  private struct OnDeadEvent
    initializer mob : L2SepulcherMonsterInstance

    def call
      case @mob.id
      when 18120..18131, 18149, 18158..18165, 18183, 18184, 18212..18219
        FourSepulchersManager.spawn_key_box(@mob)
      when 18150..18157
        FourSepulchersManager.spawn_executioner_of_halisha(@mob)
      when 18141..18148
        FourSepulchersManager.spawn_monster(@mob.mysterious_box_id)
      when 18220..18240
        FourSepulchersManager.spawn_archon_of_halisha(@mob.mysterious_box_id)
      when 25339, 25342, 25346, 25349
        FourSepulchersManager.spawn_emperors_grave_npc(@mob.mysterious_box_id)
      else
        # [automatically added else]
      end

    end
  end

  private struct ChangeImmortal
    initializer mob : L2SepulcherMonsterInstance

    def call
      FAKE_PETRIFICATION.skill.apply_effects(@mob, @mob)
    end
  end
end
