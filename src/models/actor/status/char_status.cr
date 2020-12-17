class CharStatus
  include Synchronizable

  private REGEN_FLAG_CP = 4i8
  private REGEN_FLAG_HP = 1i8
  private REGEN_FLAG_MP = 2i8

  @flags_regen_active = 0i8
  @reg_task : TaskScheduler::PeriodicTask?

  getter current_hp = 0.0
  getter current_mp = 0.0
  getter(status_listener) { Concurrent::Set(L2Character).new }

  getter_initializer active_char : L2Character

  def add_status_listener(char : L2Character)
    unless char == @active_char
      status_listener.add(char)
    end
  end

  def remove_status_listener(char : L2Character)
    status_listener.delete(char)
  end

  def reduce_cp(value : Int32)
    # no-op
  end

  def reduce_hp(value : Float64, attacker : L2Character?)
    reduce_hp(value, attacker, true, false, false)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, hp_consume : Bool)
    reduce_hp(value, attacker, true, false, hp_consume)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool)
    char = @active_char
    if char.dead?
      return
    end
    if (char.invul? || char.hp_blocked?) && !(dot || hp_consume)
      return
    end

    pc_attacker = attacker.try &.acting_player
    if pc_attacker && pc_attacker.gm?
      unless pc_attacker.access_level.can_give_damage?
        return
      end
    end

    if !dot && !hp_consume
      char.stop_effects_on_damage(awake)
      if char.stunned? && Rnd.rand(10) == 0
        char.stop_stunning(true)
      end
    end

    if value > 0
      self.current_hp = Math.max(current_hp - value, 0).to_f64
    end

    if char.current_hp < 0.5 && char.mortal?
      char.abort_attack
      char.abort_cast
      char.do_die(attacker)
    end
  end

  def reduce_mp(value : Float64)
    self.current_mp = Math.max(current_mp - value, 0.0)
  end

  def start_hp_mp_regeneration
    if !@reg_task && @active_char.alive?
      period = Formulas.get_regenerate_period(@active_char)
      task = RegenTask.new(self)
      @reg_task = ThreadPoolManager.schedule_effect_at_fixed_rate(task, period, period)
    end
  end

  def stop_hp_mp_regeneration
    if task = @reg_task
      task.cancel
      @reg_task = nil
      @flags_regen_active = 0i8
    end
  end

  def current_cp : Float64
    0.0
  end

  def current_cp=(new_cp : Float64)
    set_current_cp(new_cp)
  end

  def set_current_cp(new_cp : Float64)
    # no-op
  end

  def current_hp=(new_hp : Float64)
    set_current_hp(new_hp)
  end

  def set_current_hp(new_hp : Float64) : Bool
    set_current_hp(new_hp, true)
  end

  def set_current_hp(new_hp : Float64, broadcast : Bool) : Bool
    char = @active_char
    new_hp = new_hp.to_f
    current_hp = current_hp().to_i
    max_hp = char.max_hp

    return false if char.dead?

    if new_hp >= max_hp
      @current_hp = max_hp.to_f
      @flags_regen_active &= ~REGEN_FLAG_HP
      if @flags_regen_active == 0
        stop_hp_mp_regeneration
      end
    else
      @current_hp = new_hp
      @flags_regen_active |= REGEN_FLAG_HP
      start_hp_mp_regeneration
    end

    changed = current_hp != @current_hp

    if changed && broadcast
      char.broadcast_status_update
    end

    changed
  end

  def set_current_hp_mp(new_hp : Float64, new_mp : Float64)
    if set_current_hp(new_hp, false) | set_current_mp(new_mp, false)
      @active_char.broadcast_status_update
    end
  end

  def current_mp=(new_mp : Float64)
    set_current_mp(new_mp)
  end

  def set_current_mp(new_mp : Float64) : Bool
    set_current_mp(new_mp, true)
  end

  def set_current_mp(new_mp : Float64, broadcast : Bool)
    char = @active_char
    new_mp = new_mp.to_f
    current_mp = current_mp().to_i
    max_mp = char.max_mp

    sync do
      if char.dead?
        return false
      end

      if new_mp >= max_mp
        @current_mp = max_mp.to_f
        @flags_regen_active &= ~REGEN_FLAG_MP
        if @flags_regen_active == 0
          stop_hp_mp_regeneration
        end
      else
        @current_mp = new_mp
        @flags_regen_active |= REGEN_FLAG_MP
        start_hp_mp_regeneration
      end
    end

    changed = current_mp != @current_mp

    if changed && broadcast
      char.broadcast_status_update
    end

    changed
  end

  def do_regeneration
    char = @active_char

    if current_hp < char.max_recoverable_hp
      set_current_hp(current_hp + Formulas.hp_regen(char), false)
    end

    if current_mp < char.max_recoverable_mp
      set_current_mp(current_mp + Formulas.mp_regen(char), false)
    end

    if current_hp >= char.max_recoverable_hp
      if current_mp >= char.max_mp
        stop_hp_mp_regeneration
      end
    end

    if char.in_active_region?
      char.broadcast_status_update
    end
  end

  private struct RegenTask
    initializer status : CharStatus

    def call
      @status.do_regeneration
    end
  end
end
