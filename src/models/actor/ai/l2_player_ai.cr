require "./l2_playable_ai"

class L2PlayerAI < L2PlayableAI
  @thinking = false

  getter next_intention : IntentionCommand?

  def save_next_intention(intention : Intention, arg0 : IntentionArgType = nil, arg1 : IntentionArgType = nil)
    @next_intention = IntentionCommand.new(intention, arg0, arg1)
  end

  private def change_intention(intention : Intention, arg0 : IntentionArgType = nil, arg1 : IntentionArgType = nil)
    sync do
      if !intention.cast? || (arg0.is_a?(Skill) && !arg0.toggle?)
        @next_intention = nil
        return super
      end

      if @intention == intention
        if arg0 == @intention_arg_0 && arg1 == @intention_arg_1
          return super
        end
      end

      save_next_intention(@intention, @intention_arg_0, @intention_arg_1)
      super
    end
  end

  private def on_event_ready_to_act
    if ni = @next_intention
      set_intention(ni.intention, ni.arg_0, ni.arg_1)
      @next_intention = nil
    end

    super
  end

  private def on_event_cancel
    @next_intention = nil
    super
  end

  private def on_event_finish_casting
    if intention.cast?
      if ni = @next_intention
        if ni.intention.cast?
          set_intention(IDLE)
        else
          set_intention(ni.intention, ni.arg_0, ni.arg_1)
        end
      else
        set_intention(IDLE)
      end
    end
  end

  private def on_intention_rest
    unless intention.rest?
      change_intention(REST)
      self.target = nil
      if attack_target?
        self.attack_target = nil
      end
      client_stop_moving(nil)
    end
  end

  private def on_intention_active
    set_intention(IDLE)
  end

  private def on_intention_move_to(loc : Location?)
    raise "L2PlayerAI#on_intention_move_to's loc can't be nil here" unless loc
    if intention.rest?
      client_action_failed
      return
    end

    pc = @actor

    if pc.acting_player.not_nil!.duel_state.dead?
      client_action_failed
      pc.send_packet(SystemMessageId::CANNOT_MOVE_FROZEN)
      return
    end

    if pc.all_skills_disabled? || pc.casting_now? || pc.attacking_now?
      client_action_failed
      save_next_intention(MOVE_TO, loc)
      return
    end

    change_intention(MOVE_TO, loc)
    client_stop_auto_attack
    pc.abort_attack
    move_to(*loc.xyz)
  end

  private def client_notify_dead
    @client_moving_to_pawn_offset = 0
    @client_moving = false

    super
  end

  private def think_attack
    unless target = attack_target?
      return
    end

    if check_target_lost_or_dead(target)
      self.attack_target = nil
      return
    end

    if maybe_move_to_pawn(target, @actor.physical_attack_range)
      return
    end

    client_stop_moving(nil)
    @actor.do_attack(target)
  end

  private def think_cast
    unless skill = @skill
      return
    end

    target = cast_target?
    pc = @actor

    if skill.target_type.ground?
      pos = pc.acting_player.not_nil!.current_skill_world_position
      range = pc.get_magical_attack_range(skill)

      if maybe_move_to_position(pos, range)
        pc.casting_now = false
        return
      end
    else
      if check_target_lost(target)
        if skill.bad? && attack_target?
          self.cast_target = nil
        end

        pc.casting_now = false
        return
      end

      if target
        if maybe_move_to_pawn(target, pc.get_magical_attack_range(skill))
          pc.casting_now = false
          return
        end
      end
    end

    if skill.hit_time > 50 && !skill.simultaneous_cast?
      client_stop_moving(nil)
    end

    pc.do_cast(skill)
  end

  private def think_pick_up
    return if @actor.all_skills_disabled? || @actor.casting_now?
    target = target()
    return if check_target_lost(target)
    return if maybe_move_to_pawn(target, 36)

    set_intention(IDLE)
    @actor.acting_player.not_nil!.do_pickup_item(target.as(L2ItemInstance))
  end

  private def think_interact
    if @actor.all_skills_disabled? || @actor.casting_now?
      return
    end

    target = target()

    if check_target_lost(target)
      return
    end

    if maybe_move_to_pawn(target, 36)
      return
    end

    unless target.is_a?(L2StaticObjectInstance)
      @actor.acting_player.not_nil!.do_interact(target.as(L2Character))
    end

    set_intention(IDLE)
  end

  private def on_event_think
    if @thinking && !intention.cast?
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
end
