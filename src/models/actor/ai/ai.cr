require "./next_action"
require "../../../task_managers/attack_stances"

abstract class AI
  include Loggable
  include Synchronizable
  include Packets::Outgoing

  enum Intention : UInt8
    IDLE
    ACTIVE
    REST
    ATTACK
    CAST
    MOVE_TO
    FOLLOW
    PICK_UP
    INTERACT
  end

  enum Event : UInt8
    THINK
    ATTACKED
    AGGRESSION
    STUNNED
    PARALYZED
    SLEEPING
    ROOTED
    EVADED
    READY_TO_ACT
    USER_CMD
    ARRIVED
    ARRIVED_REVALIDATE
    ARRIVED_BLOCKED
    FORGET_OBJECT
    CANCEL
    DEAD
    FAKE_DEATH
    CONFUSED
    MUTED
    AFRAID
    FINISH_CASTING
    BETRAYED
  end

  {% for const in Intention.constants %}
    {{const.id}} = Intention::{{const.id}}
  {% end %}

  {% for const in Event.constants %}
    {{const.id}} = Event::{{const.id}}
  {% end %}

  private FOLLOW_INTERVAL = 1000
  private ATTACK_FOLLOW_INTERVAL = 500

  # Use Object instead if/when Crystal supports it.
  private alias AIArg = L2Object | Skill | Location | Nil

  @move_to_pawn_timeout = 0
  @client_moving_to_pawn_offset = 0
  @intention_arg_0 : AIArg
  @intention_arg_1 : AIArg
  @skill : Skill?
  @client_moving = false
  @client_auto_attacking = false
  getter intention = IDLE
  protected getter! follow_target : L2Character
  property next_action : NextAction?
  property follow_task : Scheduler::PeriodicTask?
  private property target : L2Object?
  property! cast_target : L2Character?
  property! attack_target : L2Character?

  getter_initializer actor : L2Character

  def change_intention(intention : Intention, arg0 : AIArg = nil, arg1 : AIArg = nil)
    sync do
      @intention = intention
      @intention_arg_0 = arg0
      @intention_arg_1 = arg1
    end
  end

  def intention=(intention : Intention)
    set_intention(intention)
  end

  def set_intention(intention : Intention, arg0 : AIArg = nil, arg1 : AIArg = nil)
    if !intention.follow? && !intention.attack?
      stop_follow
    end

    case intention
    when IDLE
      on_intention_idle
    when ACTIVE
      on_intention_active
    when REST
      on_intention_rest
    when ATTACK
      if arg0.is_a?(L2Character)
        on_intention_attack(arg0)
      else
        error "Wrong types for on_intention_attack: arg0: #{arg0}, arg1: #{arg1}"
      end
    when CAST
      if arg0.is_a?(Skill) && arg1.is_a?(L2Object?)
        on_intention_cast(arg0, arg1)
      else
        error "Wrong types for on_intention_cast: arg0: #{arg0}, arg1: #{arg1}"
      end
    when MOVE_TO
      if arg0.is_a?(Location)
        on_intention_move_to(arg0)
      else
        error "Wrong types for on_intention_move_to: arg0: #{arg0}, arg1: #{arg1}"
      end
    when FOLLOW
      if arg0.is_a?(L2Character)
        on_intention_follow(arg0)
      else
        error "Wrong types for on_intention_follow: arg0: #{arg0}, arg1: #{arg1}"
      end
    when PICK_UP
      if arg0.is_a?(L2Object)
        on_intention_pick_up(arg0)
      else
        error "Wrong types for on_intention_pick_up: arg0: #{arg0}, arg1: #{arg1}"
      end
    when INTERACT
      if arg0.is_a?(L2Object)
        on_intention_interact(arg0)
      else
        error "Wrong types for on_intention_interact: arg0: #{arg0}, arg1: #{arg1}"
      end
    end

    if @next_action.try &.intention?(intention)
      @next_action = nil
    end
  end

  def notify_event(event : Event, arg0 = nil, arg1 = nil)
    if (!@actor.visible? && !@actor.teleporting?) || !@actor.ai?
      return
    end

    case event
    when THINK
      on_event_think
    when ATTACKED
      if arg0.is_a?(L2Character?)
        on_event_attacked(arg0)
      else
        raise "Wrong type for on_event_attacked: #{arg0.class}"
      end
    when AGGRESSION
      if arg0.is_a?(L2Character?) && arg1.is_a?(Number)
        on_event_aggression(arg0, arg1)
      else
        raise "Wrong type for on_event_aggression: #{arg0.class}, #{arg1.class}"
      end
    when STUNNED
      if arg0.is_a?(L2Character?)
        on_event_stunned(arg0)
      else
        raise "Wrong type for on_event_stunned: #{arg0.class}"
      end
    when PARALYZED
      if arg0.is_a?(L2Character?)
        on_event_paralyzed(arg0)
      else
        raise "Wrong type for on_event_paralyzed: #{arg0.class}"
      end
    when SLEEPING
      if arg0.is_a?(L2Character?)
        on_event_sleeping(arg0)
      else
        raise "Wrong type for on_event_sleeping: #{arg0.class}"
      end
    when ROOTED
      if arg0.is_a?(L2Character?)
        on_event_rooted(arg0)
      else
        raise "Wrong type for on_event_rooted: #{arg0.class}"
      end
    when CONFUSED
      if arg0.is_a?(L2Character?)
        on_event_confused(arg0)
      else
        raise "Wrong type for on_event_confused: #{arg0.class}"
      end
    when MUTED
      if arg0.is_a?(L2Character?)
        on_event_muted(arg0)
      else
        raise "Wrong type for on_event_muted: #{arg0.class}"
      end
    when EVADED
      if arg0.is_a?(L2Character?)
        on_event_evaded(arg0)
      else
        raise "Wrong type for on_event_evaded: #{arg0.class}"
      end
    when READY_TO_ACT
      if !@actor.casting_now? && !@actor.casting_simultaneously_now?
        on_event_ready_to_act
      end
    when USER_CMD
      on_event_user_cmd(arg0, arg1)
    when ARRIVED
      if !@actor.casting_now? && !@actor.casting_simultaneously_now?
        on_event_arrived
      end
    when ARRIVED_REVALIDATE
      if @actor.moving?
        on_event_arrived_revalidate
      end
    when ARRIVED_BLOCKED
      if arg0.is_a?(Location?)
        on_event_arrived_blocked(arg0)
      else
        raise "Wrong type for on_event_arrived_blocked: #{arg0.class}"
      end
    when FORGET_OBJECT
      if arg0.is_a?(L2Object?)
        on_event_forget_object(arg0)
      else
        raise "Wrong type for on_event_forget_object: #{arg0.class}"
      end
    when CANCEL
      on_event_cancel
    when DEAD
      on_event_dead
    when FAKE_DEATH
      on_event_fake_death
    when FINISH_CASTING
      on_event_finish_casting
    when AFRAID
      if arg0.is_a?(L2Character?) && arg1.is_a?(Bool)
        on_event_afraid(arg0, arg1)
      else
        raise "Wrong types for on_event_afraid: #{arg0.class}, #{arg1.class}"
      end
    end

    if (ni = @next_action) && ni.event?(event)
      ni.do_action
    end
  end

  abstract def on_intention_idle
  abstract def on_intention_active
  abstract def on_intention_rest
  abstract def on_intention_attack(attacker)
  abstract def on_intention_cast(skill, target)
  abstract def on_intention_move_to(loc)
  abstract def on_intention_follow(target)
  abstract def on_intention_pick_up(object)
  abstract def on_intention_interact(object)
  abstract def on_event_think
  abstract def on_event_attacked(attacker)
  abstract def on_event_aggression(target, aggro)
  abstract def on_event_stunned(attacker)
  abstract def on_event_paralyzed(attacker)
  abstract def on_event_sleeping(attacker)
  abstract def on_event_rooted(attacker)
  abstract def on_event_confused(attacker)
  abstract def on_event_muted(attacker)
  abstract def on_event_evaded(attacker)
  abstract def on_event_ready_to_act
  abstract def on_event_user_cmd(arg0, arg1)
  abstract def on_event_arrived
  abstract def on_event_arrived_revalidate
  abstract def on_event_arrived_blocked(loc)
  abstract def on_event_forget_object(object)
  abstract def on_event_cancel
  abstract def on_event_dead
  abstract def on_event_fake_death
  abstract def on_event_finish_casting
  abstract def on_event_afraid(effector, start : Bool)

  private def client_action_failed
    if pc = @actor.as?(L2PcInstance)
      pc.action_failed
    end
  end

  protected def move_to_pawn(pawn : L2Object, offset : Int32)
    if @actor.movement_disabled?
      client_action_failed
      return
    end

    offset = 10 if offset < 10

    send_packet = true
    ticks = GameTimer.ticks

    if @client_moving && @target == pawn
      if @client_moving_to_pawn_offset == offset
        if ticks < @move_to_pawn_timeout
          return
        end
        send_packet = false
      elsif @actor.on_geodata_path?
        if ticks < @move_to_pawn_timeout + 10
          return
        end
      end
    end

    @client_moving = true
    @client_moving_to_pawn_offset = offset
    @target = pawn
    @move_to_pawn_timeout = ticks + (1000 // GameTimer::MILLIS_IN_TICK)

    unless pawn
      warn "AI#move_to_pawn: char to follow is nil."
      return
    end

    @actor.move_to_location(*pawn.xyz, offset)

    unless @actor.moving?
      client_action_failed
      return
    end

    if pawn.is_a?(L2Character)
      if @actor.on_geodata_path?
        @actor.broadcast_packet(MoveToLocation.new(@actor))
        @client_moving_to_pawn_offset = 0
      elsif send_packet
        @actor.broadcast_packet(MoveToPawn.new(@actor, pawn, offset))
      end
    else
      @actor.broadcast_packet(MoveToLocation.new(@actor))
    end
  end

  private def move_to(x : Int32, y : Int32, z : Int32)
    if @actor.movement_disabled?
      client_action_failed
      return
    end

    @client_moving = true
    @client_moving_to_pawn_offset = 0
    @actor.move_to_location(x, y, z, 0)
    @actor.broadcast_packet(MoveToLocation.new(@actor))
  end

  # custom
  private def client_stop_moving
    client_stop_moving(nil)
  end

  private def client_stop_moving(loc : Location?)
    if @actor.moving?
      @actor.stop_move(loc)
    end

    @client_moving_to_pawn_offset = 0

    if @client_moving || loc
      @client_moving = false
      @actor.broadcast_packet(StopMove.new(@actor))
      if loc
        @actor.broadcast_packet(StopRotation.new(@actor.l2id, loc.heading, 0))
      end
    end
  end

  private def client_stopped_moving
    if @client_moving_to_pawn_offset > 0
      @client_moving_to_pawn_offset = 0
      @actor.broadcast_packet(StopMove.new(@actor))
    end

    @client_moving = false
  end

  def auto_attacking? : Bool
    @client_auto_attacking
  end

  def auto_attacking=(val : Bool)
    me = @actor
    if me.is_a?(L2Summon)
      if owner = me.owner?
        owner.ai.auto_attacking = val
      end

      return
    end

    @client_auto_attacking = val
  end

  def client_start_auto_attack
    me = @actor
    if me.is_a?(L2Summon)
      if owner = me.owner?
        owner.ai.client_start_auto_attack
      end

      return
    end

    unless auto_attacking?
      if @actor.player?
        if smn = @actor.summon
          smn.broadcast_packet(AutoAttackStart.new(smn.l2id))
        end
      end

      @actor.broadcast_packet(AutoAttackStart.new(@actor.l2id))
      self.auto_attacking = true
    end

    AttackStances << @actor
  end

  def client_stop_auto_attack
    me = @actor
    if me.is_a?(L2Summon)
      if owner = me.owner?
        owner.ai.client_stop_auto_attack
      end

      return
    end

    if @actor.player?
      if !AttackStances.includes?(@actor) && auto_attacking?
        AttackStances << @actor
      end
    elsif auto_attacking?
      @actor.broadcast_packet(AutoAttackStop.new(@actor.l2id))
      self.auto_attacking = false
    end
  end

  private def client_notify_dead
    @actor.broadcast_packet(Die.new(@actor))

    @intention = IDLE
    @target = nil
    @cast_target = nil
    @attack_target = nil

    stop_follow
  end

  def describe_state_to_player(pc : L2PcInstance)
    if actor.visible_for?(pc) && @client_moving
      if @client_moving_to_pawn_offset != 0 && (target = @follow_target)
        mtp = MoveToPawn.new(@actor, target, @client_moving_to_pawn_offset)
        pc.send_packet(mtp)
      else
        pc.send_packet(MoveToLocation.new(@actor))
      end
    end
  end

  def start_follow(target : L2Character)
    sync do
      if task = @follow_task
        task.cancel
        @follow_task = nil
      end

      @follow_target = target

      task = FollowTask.new(@actor)
      @follow_task = ThreadPoolManager.schedule_ai_at_fixed_rate(task, 5, FOLLOW_INTERVAL)
    end
  end

  def start_follow(target : L2Character, range : Int32)
    sync do
      if task = @follow_task
        task.cancel
        @follow_task = nil
      end

      @follow_target = target

      task = FollowTask.new(@actor, range)
      @follow_task = ThreadPoolManager.schedule_ai_at_fixed_rate(task, 5, ATTACK_FOLLOW_INTERVAL)
    end
  end

  def stop_follow
    sync do
      if task = @follow_task
        task.cancel
        @follow_task = nil
      end
      @follow_target = nil
    end
  end

  def stop_ai_task
    stop_follow
  end

  struct FollowTask
    include Loggable

    def initialize(@char : L2Character, @range : Int32 = 70)
    end

    def call
      return unless @char.ai.follow_task

      unless target = @char.ai.follow_target
        if @char.summon?
          @char.as(L2Summon).follow_status = false
          @char.intention = AI::IDLE
        end

        return
      end

      unless @char.inside_radius?(target, @range, true, false)
        unless @char.inside_radius?(target, 3000, true, false)
          if @char.summon?
            @char.as(L2Summon).follow_status = false
          end
          @char.intention = AI::IDLE
          return
        end
        @char.ai.move_to_pawn(target, @range)
      end
    rescue e
      error e
    end
  end

  def to_s(io : IO)
    super
    io << '('
    actor.to_s(io)
    io << ')'
  end
end
