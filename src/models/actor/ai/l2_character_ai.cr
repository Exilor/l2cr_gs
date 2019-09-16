require "./ai"
require "../l2_attackable"
require "../instance/l2_door_instance"

class L2CharacterAI < AI
  private FEAR_RANGE = 500

  private record IntentionCommand, intention : Intention, arg_0 : AIArg,
    arg_1 : AIArg

  private struct CastTask
    initializer char: L2Character, skill: Skill, target: L2Object?

    def call
      if @char.attacking_now?
        @char.abort_attack
      end
      @char.ai.change_intention_to_cast(@skill, @target)
    end
  end

  def next_intention : IntentionCommand?
    # return nil
  end

  private def on_event_attacked(attacker)
    if attacker.is_a?(L2Attackable) && !attacker.core_ai_disabled?
      client_start_auto_attack
    end
  end

  private def on_intention_idle
    change_intention(IDLE)
    self.cast_target = nil
    self.attack_target = nil
    client_stop_moving
    client_stop_auto_attack
  end

  private def on_intention_active
    if intention.active?
      return
    end

    change_intention(ACTIVE)
    self.cast_target = nil
    self.attack_target = nil
    client_stop_moving
    client_stop_auto_attack
    @actor.as?(L2Attackable).try &.start_random_animation_timer
    on_event_think
  end

  private def on_intention_rest
    set_intention(IDLE)
  end

  private def on_intention_attack(target)
    unless target
      client_action_failed
      return
    end

    if intention.rest?
      client_action_failed
      return
    end

    if @actor.all_skills_disabled? || @actor.casting_now? || @actor.afraid?
      client_action_failed
      return
    end

    if intention.attack?
      if attack_target? != target
        self.attack_target = target
        stop_follow
        notify_event(THINK)
      else
        client_action_failed
      end
    else
      change_intention(ATTACK, target)
      self.attack_target = target
      stop_follow
      notify_event(THINK)
    end
  end

  private def on_intention_cast(skill : Skill, target : L2Object?)
    if intention.rest? && skill.magic?
      client_action_failed
      @actor.casting_now = false
      return
    end

    ticks = GameTimer.ticks

    if @actor.bow_attack_end_time > ticks
      delay = @actor.bow_attack_end_time - ticks
      delay *= GameTimer::MILLIS_IN_TICK
      task = CastTask.new(@actor, skill, target)
      ThreadPoolManager.schedule_general(task, delay)
    else
      change_intention_to_cast(skill, target)
    end
  end

  protected def change_intention_to_cast(skill : Skill, target : L2Object?)
    self.cast_target = target.as?(L2Character)
    @skill = skill
    change_intention(CAST, skill, target)
    notify_event(THINK)
  end

  private def on_intention_move_to(loc)
    if intention.rest? || @actor.all_skills_disabled? || @actor.casting_now?
      client_action_failed
      return
    end

    change_intention(MOVE_TO, loc)
    client_stop_auto_attack
    @actor.abort_attack
    move_to(*loc.xyz)
  end

  private def on_intention_follow(target)
    if intention.rest? || @actor.all_skills_disabled? || @actor.casting_now?
      client_action_failed
      return
    end

    if @actor.movement_disabled? || @actor.dead? || @actor == target
      client_action_failed
      return
    end

    client_stop_auto_attack
    change_intention(FOLLOW, target)
    start_follow(target)
  end

  private def on_intention_pick_up(object)
    if intention.rest? || @actor.all_skills_disabled? || @actor.casting_now?
      client_action_failed
      return
    end

    client_stop_auto_attack

    if object.is_a?(L2ItemInstance)
      unless object.item_location.void?
        debug { "#{object}'s item_location is not VOID (#{object.item_location})." }
        return
      end
    end

    change_intention(PICK_UP, object)
    self.target = object

    if object.x == 0 && object.y == 0
      warn "#on_intention_pick_up: Object in coords 0 0 - using a temporary fix."
      object.set_xyz(actor.x, actor.y, actor.z + 5)
    end

    move_to_pawn(object, 20)
  end

  private def on_intention_interact(object)
    if intention.rest? || @actor.all_skills_disabled? || @actor.casting_now?
      client_action_failed
      return
    end

    client_stop_auto_attack

    unless intention.interact?
      change_intention(INTERACT, object)
      self.target = object
      move_to_pawn(object, 60)
    end
  end

  private def on_event_think
    # no-op
  end

  private def on_event_aggression(target, aggro)
    # no-op
  end

  private def on_event_stunned(attacker)
    @actor.broadcast_packet(AutoAttackStop.new(@actor.l2id))

    if AttackStances.includes?(@actor)
      AttackStances.delete(@actor)
    end

    self.auto_attacking = false
    client_stop_moving
    on_event_attacked(attacker)
  end

  private def on_event_paralyzed(attacker)
    @actor.broadcast_packet(AutoAttackStop.new(@actor.l2id))

    if AttackStances.includes?(@actor)
      AttackStances.delete(@actor)
    end

    self.auto_attacking = false
    client_stop_moving
    on_event_attacked(attacker)
  end

  private def on_event_sleeping(attacker)
    @actor.broadcast_packet(AutoAttackStop.new(@actor.l2id))

    if AttackStances.includes?(@actor)
      AttackStances.delete(@actor)
    end

    self.auto_attacking = false
    client_stop_moving
  end

  private def on_event_rooted(attacker)
    client_stop_moving
    on_event_attacked(attacker)
  end

  private def on_event_confused(attacker)
    client_stop_moving
    on_event_attacked(attacker)
  end

  private def on_event_muted(attacker)
    on_event_attacked(attacker)
  end

  private def on_event_evaded(attacker)
    # no-op
  end

  private def on_event_ready_to_act
    on_event_think
  end

  private def on_event_user_cmd(arg_0, arg_1) # Object, Object
    # no-op
  end

  private def on_event_arrived
    @actor.revalidate_zone(true)

    if @actor.move_to_next_route_point
      return
    end

    @actor.as?(L2Attackable).try &.returning_to_spawn_point = false

    client_stopped_moving

    if npc = @actor.as?(L2Npc)
      WalkingManager.on_arrived(npc)
      OnNpcMoveFinished.new(npc).async(npc)
    end

    if intention.move_to?
      set_intention(ACTIVE)
    end

    on_event_think
  end

  private def on_event_arrived_revalidate
    on_event_think
  end

  private def on_event_arrived_blocked(loc)
    if intention.move_to? || intention.cast?
      set_intention(ACTIVE)
    end

    client_stop_moving(loc)
    on_event_think
  end

  private def on_event_forget_object(object)
    if target == object
      self.target = nil

      if intention.interact? || intention.pick_up?
        set_intention(ACTIVE)
      end
    end

    if attack_target? == object
      self.attack_target = nil
      set_intention(ACTIVE)
    end

    if cast_target? == object
      self.cast_target = nil
      set_intention(ACTIVE)
    end

    if follow_target? == object
      client_stop_moving
      stop_follow
      set_intention(ACTIVE)
    end

    if @actor == object
      self.target = nil
      self.cast_target = nil
      self.attack_target = nil
      stop_follow
      client_stop_moving
      change_intention(IDLE)
    end
  end

  private def on_event_cancel
    @actor.abort_cast
    stop_follow

    unless AttackStances.includes?(@actor)
      @actor.broadcast_packet(AutoAttackStop.new(@actor.l2id))
    end

    on_event_think
  end

  private def on_event_dead
    stop_ai_task
    client_notify_dead

    unless @actor.playable?
      @actor.set_walking
    end
  end

  private def on_event_fake_death
    stop_follow
    client_stop_moving
    @intention = IDLE
    self.target = nil
    self.cast_target = nil
    self.attack_target = nil
  end

  private def on_event_finish_casting
    # no-op
  end

  private def on_event_afraid(effector, start)
    if start
      angle = Util.calculate_angle_from(effector, @actor)
      radians = Math.to_radians(angle)
    else
      degree = Util.convert_heading_to_degree(@actor.heading)
      radians = Math.to_radians(degree)
    end

    pos_x = (@actor.x + (FEAR_RANGE * Math.cos(radians))).to_i
    pos_y = (@actor.y + (FEAR_RANGE * Math.sin(radians))).to_i
    pos_z = @actor.z

    unless @actor.pet?
      @actor.set_running
    end

    if Config.pathfinding > 0
      dst = GeoData.move_check(
        *@actor.xyz,
        pos_x, pos_y, pos_z,
        @actor.instance_id
      )
    else
      dst = Location.new(pos_x, pos_y, pos_z, @actor.instance_id)
    end

    set_intention(MOVE_TO, dst)
  end

  private def maybe_move_to_position(loc : Location?, offset : Int32) : Bool
    unless loc
      warn "L2CharacterAI#maybe_move_to_position: given loc is nil."
      return false
    end

    if offset < 0
      return false
    end

    radius = offset + @actor.template.collision_radius

    unless @actor.inside_radius?(loc, radius, false, false)
      if @actor.movement_disabled?
        return true
      end

      if !@actor.running? && !is_a?(L2PlayerAI) && !is_a?(L2SummonAI)
        @actor.set_running
      end

      stop_follow

      x = @actor.x
      y = @actor.y
      dx = (loc.x - x).to_f
      dy = (loc.y - y).to_f

      dist = Math.hypot(dx, dy)

      sin = dy / dist
      cos = dx / dist

      dist -= offset - 5

      x += (dist * cos).to_i
      y += (dist * sin).to_i

      move_to(x, y, loc.z)

      return true
    end

    if follow_target?
      stop_follow
    end

    false
  end

  private def maybe_move_to_pawn(target : L2Object?, offset : Int32) : Bool
    unless target
      warn "L2CharacterAI#maybe_move_to_pawn: given target is nil."
      return false
    end

    if offset < 0
      return false
    end

    offset += @actor.template.collision_radius
    if target.is_a?(L2Character)
      offset += target.template.collision_radius
    end

    if target.is_a?(L2DoorInstance)
      x_point = target.template.node_x.sum / 4
      y_point = target.template.node_y.sum / 4
      need_to_move = !@actor.inside_radius?(
        x_point, y_point, target.template.node_z, offset, false, false
      )
    else
      need_to_move = !@actor.inside_radius?(target, offset, false, false)
    end

    if need_to_move
      if follow_target?
        unless @actor.inside_radius?(target, offset + 100, false, false)
          return true
        end

        stop_follow
        return false
      end

      if @actor.movement_disabled?
        if intention.attack?
          set_intention(IDLE)
        end

        return true
      end

      if intention.cast? && @actor.player? && @actor.transformed?
        unless @actor.transformation.combat?
          @actor.send_packet(SystemMessageId::DIST_TOO_FAR_CASTING_STOPPED)
          @actor.action_failed
          return true
        end
      end

      if !@actor.running? && !is_a?(L2PlayerAI) && !is_a?(L2SummonAI)
        @actor.set_running
      end

      stop_follow

      if target.is_a?(L2Character) && !target.is_a?(L2DoorInstance)
        offset -= 100 if target.moving?
        offset = 5 if offset < 5
        start_follow(target, offset)
      else
        move_to_pawn(target, offset)
      end

      return true
    end

    if follow_target?
      stop_follow
    end

    false
  end

  private def check_target_lost_or_dead(target) : Bool
    if target.nil? || target.looks_dead?
      if target.is_a?(L2PcInstance) && target.fake_death?
        target.stop_fake_death(true)
        return false
      end

      set_intention(ACTIVE)
      return true
    end

    false
  end

  private def check_target_lost(target) : Bool
    if target.is_a?(L2PcInstance)
      if target.fake_death?
        target.stop_fake_death(true)
        return false
      end
    end

    unless target
      set_intention(ACTIVE)
      return true
    end

    if (skill = @skill) && skill.bad? && skill.affect_range > 0
      unless GeoData.can_see_target?(@actor, target)
        set_intention(ACTIVE)
        return true
      end
    end

    false
  end

  def can_aura?(sk)
    tt = sk.target_type
    if tt.aura? || tt.behind_aura? || tt.front_aura? || tt.aura_corpse_mob? || tt.aura_undead_enemy?
      @actor.known_list.each_character(sk.affect_range) do |target|
        return true if target == attack_target?
      end
    end

    false
  end

  def can_aoe?(sk)
    tt = sk.target_type
    if sk.has_effect_type?(L2EffectType::DISPEL)
      if tt.aura? || tt.behind_aura? || tt.front_aura? || tt.aura_corpse_mob? || tt.aura_undead_enemy?
        can_cast = true
        @actor.known_list.each_character(sk.affect_range) do |target|
          next unless GeoData.can_see_target?(@actor, target)
          if target.is_a?(L2Attackable)
            next unless target.chaos?
          end
          if target.affected_by_skill?(sk.id)
            can_cast = false
          end
        end

        return true if can_cast
      elsif tt.area? || tt.behind_area? || tt.front_area?
        can_cast = true
        @actor.known_list.each_character(sk.affect_range) do |target|
          next unless GeoData.can_see_target?(@actor, target)
          if target.is_a?(L2Attackable)
            next unless target.chaos?
          end
          unless target.effect_list.empty?
            can_cast = true
          end
        end

        return true if can_cast
      end
    else
      if tt.aura? || tt.behind_aura? || tt.front_aura? || tt.aura_corpse_mob? || tt.aura_undead_enemy?
        can_cast = true
        @actor.known_list.each_character(sk.affect_range) do |target|
          next unless GeoData.can_see_target?(@actor, target)
          if target.is_a?(L2Attackable)
            next unless target.chaos?
          end
          unless target.effect_list.empty?
            can_cast = true
          end
        end

        return true if can_cast
      elsif tt.area? || tt.behind_area? || tt.front_area?
        can_cast = true
        @actor.known_list.each_character(sk.affect_range) do |target|
          next unless GeoData.can_see_target?(@actor, target)
          if target.is_a?(L2Attackable)
            next unless target.chaos?
          end
          if target.affected_by_skill?(sk.id)
            can_cast = false
          end
        end

        return true if can_cast
      end
    end

    false
  end

  def can_party?(sk : Skill) : Bool
    if party?(sk)
      count = 0
      count2 = 0
      @actor.known_list.each_character(sk.affect_range) do |target|
        next unless target.is_a?(L2Attackable)
        next unless GeoData.can_see_target?(@actor, target)
        targets = target.as(L2Npc)
        actors = @actor.as(L2Npc)

        if targets.in_my_clan?(actors)
          count += 1
          if target.affected_by_skill?(sk.id)
            count2 += 1
          end
        end
      end

      return true if count2 < count
    end

    false
  end

  def party?(sk : Skill) : Bool
    sk.target_type.party?
  end
end
