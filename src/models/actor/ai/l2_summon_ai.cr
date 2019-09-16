require "./l2_playable_ai"

class L2SummonAI < L2PlayableAI
  private AVOID_RADIUS = 70

  @thinking = false
  @start_avoid = false
  @start_follow : Bool
  @avoid_task : Concurrent::PeriodicTask?
  @last_attack : L2Character?

  def initialize(summon : L2Summon)
    super

    @start_follow = summon.follow_status
  end

  private def on_intention_attack(target)
    if Config.pathfinding > 0
      if PathFinding.find_path(
          *@actor.xyz,
          *target.xyz,
          @actor.instance_id, true
        )
      else
        debug "#{@actor} can't find path to #{target}."
        return
      end
    end

    super
  end

  private def on_intention_idle
    stop_follow
    @start_follow = false
    on_intention_active
  end

  private def on_intention_active
    if @start_follow
      set_intention(FOLLOW, @actor.as(L2Summon).owner)
    else
      super
    end
  end

  def change_intention(intention, arg0 = nil, arg1 = nil)
    sync do
      case intention
      when ACTIVE, FOLLOW
        start_avoid_task
      else
        stop_avoid_task
      end

      super
    end
  end

  private def think_attack
    if check_target_lost_or_dead(attack_target?)
      self.attack_target = nil
      return
    end

    if maybe_move_to_pawn(attack_target, @actor.physical_attack_range)
      return
    end

    client_stop_moving
    @actor.do_attack(attack_target)
  end

  private def think_cast
    if check_target_lost(cast_target)
      return self.cast_target = nil
    end

    val = @start_follow

    if maybe_move_to_pawn(cast_target, @actor.get_magical_attack_range(@skill))
      return
    end

    client_stop_moving
    @actor.as(L2Summon).follow_status = false
    set_intention(IDLE)
    @start_follow = val
    @actor.do_cast(@skill.not_nil!)
  end

  private def think_pick_up
    return if check_target_lost(target)
    return if maybe_move_to_pawn(target, 36)
    set_intention(IDLE)
    @actor.as(L2Summon).do_pickup_item(target.not_nil!)
  end

  private def think_interact
    return if check_target_lost(target)
    return if maybe_move_to_pawn(target, 36)
    set_intention(IDLE)
  end

  private def on_event_think
    if @thinking || @actor.casting_now? || @actor.all_skills_disabled?
      return
    end

    @thinking = true

    begin
      case intention
      when ATTACK
        think_attack
      when CAST
        think_cast
      when PICK_UP
        think_pick_up
      when INTERACT
        think_interact
      end
    ensure
      @thinking = false
    end
  end

  private def on_event_finish_casting
    if attack = @last_attack
      set_intention(ATTACK, attack)
      @last_attack = nil
    else
      @actor.as(L2Summon).follow_status = @start_follow
    end
  end

  private def on_event_attacked(attacker)
    super
    avoid_attack(attacker)
  end

  private def on_event_evaded(attacker)
    super
    avoid_attack(attacker)
  end

  private def avoid_attack(attacker)
    owner = @actor.as(L2Summon).owner?
    if owner && owner != attacker
      if owner.inside_radius?(@actor, AVOID_RADIUS * 2, true, false)
        @start_avoid = true
      end
    end
  end

  def call
    if @start_avoid
      @start_avoid = false

      if !@client_moving && @actor.alive? && !@actor.movement_disabled?
        if @actor.casting_now?
          # This check prevents a summon from stopping a skill casting animation
          # to try to avoid an attack.
          # warn "#{@actor} was made to avoid an attack while casting."
          return
        end

        owner_x, owner_y = @actor.as(L2Summon).owner.x, @actor.as(L2Summon).owner.y

        angle = Math.to_radians(rand(-90..90))
        angle += Math.atan2(owner_y - @actor.y, owner_x - @actor.x)

        target_x = owner_x + (AVOID_RADIUS * Math.cos(angle)).to_i
        target_y = owner_y + (AVOID_RADIUS * Math.sin(angle)).to_i

        if GeoData.can_move?(*@actor.xyz, target_x, target_y, @actor.z, @actor.instance_id)
          move_to(target_x, target_y, @actor.z)
        end
      end
    end
  end

  def notify_follow_status_change
    @start_follow = !@start_follow

    case intention
    when ACTIVE, FOLLOW, IDLE, MOVE_TO, PICK_UP
      @actor.as(L2Summon).follow_status = @start_follow
    end
  end

  def start_follow_controller=(@start_follow : Bool)
  end

  private def on_intention_cast(skill, target)
    @last_attack = intention.attack? ? attack_target? : nil
    super
  end

  private def start_avoid_task
    @avoid_task ||= ThreadPoolManager.schedule_ai_at_fixed_rate(self, 100, 100)
  end

  private def stop_avoid_task
    if task = @avoid_task
      task.cancel
      @avoid_task = nil
    end
  end

  def stop_ai_task
    stop_avoid_task
    super
  end
end
