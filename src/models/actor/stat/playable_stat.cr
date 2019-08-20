require "./char_stat"

class PlayableStat < CharStat
  @exp = Atomic(Int64).new(0i64)
  @sp = Atomic(Int32).new(0)

  def exp : Int64
    @exp.get
  end

  def exp=(val : Int64)
    @exp.set(val)
  end

  def sp : Int32
    @sp.get
  end

  def sp=(val : Int32)
    @sp.set(val)
  end

  def add_exp(value : Int64) : Bool
    current_exp = exp
    total_exp = current_exp + value

    evt = OnPlayableExpChanged.new(active_char, current_exp, total_exp)
    term = EventDispatcher.notify(evt, active_char, TerminateReturn)
    if term && term.terminate
      debug "PlayableStat#add_exp OnPlayableExpChanged#terminate returned true"
      return false
    end

    exp_for_max_level = get_exp_for_level(max_exp_level)

    if total_exp < 0 || (value > 0 && current_exp == exp_for_max_level - 1)
      return true
    end

    if total_exp >= exp_for_max_level
      value = exp_for_max_level - 1 - current_exp
    end

    @exp.add(value) # there's no method to add and get the new value :(
    if value + current_exp >= get_exp_for_level(level + 1)
      sync_exp_level(true)
    end

    true
  end

  def remove_exp(exp : Int64) : Bool
    current_exp = exp()

    if current_exp < exp
      @exp.sub(current_exp)
    else
      @exp.sub(exp)
    end

    sync_exp_level(false)

    true
  end

  def remove_exp_and_sp(exp : Int64, sp : Int32) : Bool
    exp > 0 && remove_exp(exp) || sp > 0 && remove_sp(sp)
  end

  def sync_exp_level(exp_increased : Bool)
    minimum_level = active_char.min_level
    current_exp = exp
    max_level = max_level()
    current_level = level

    if exp_increased
      tmp = current_level
      while tmp <= max_level
        if current_exp >= get_exp_for_level(tmp)
          if current_exp >= get_exp_for_level(tmp + 1)
            tmp += 1
            next
          end

          if tmp < minimum_level
            tmp = minimum_level
          end

          if tmp != current_level
            new_level = tmp - current_level
            evt = OnPlayerLevelChanged.new(active_char.acting_player, current_level.to_i8, new_level.to_i8)
            evt.async(active_char)
            active_char.add_level(new_level.to_i32)
          end

          break
        end

        tmp += 1
      end
    else
      tmp = current_level
      while tmp >= minimum_level
        if current_exp < get_exp_for_level(tmp)
          if current_exp < get_exp_for_level(tmp - 1)
            tmp -= 1
            next
          end
          tmp -= 1
          if tmp < minimum_level
            tmp = minimum_level
          end

          if tmp != current_level
            new_level = tmp - current_level
            evt = OnPlayerLevelChanged.new(active_char.acting_player, current_level.to_i8, new_level.to_i8)
            evt.async(active_char)
            active_char.add_level(new_level.to_i32)
          end

          break
        end

        tmp -= 1
      end
    end
  end

  def add_level(value : Int32) : Bool
    current_level = level

    if current_level + value > max_level
      if current_level < max_level
        value = max_level - current_level
      else
        debug "Already at max level (#{max_level})."
        return false
      end
    end

    level_increased = current_level + value > current_level
    value += current_level
    self.level = value

    if exp >= get_exp_for_level(level + 1) || get_exp_for_level(level) > exp
      self.exp = get_exp_for_level(level)
    end

    unless level_increased
      debug "Level didn't increase."
      return false
    end

    @active_char.max_hp!.max_mp!

    true
  end

  def add_sp(sp : Int32) : Bool
    if sp < 0
      warn "wrong sp for PlayableStat#add_sp(sp: #{sp})"
      return false
    end

    current_sp = sp()

    if current_sp == Int32::MAX
      return false
    end

    if sp > Int32::MAX - current_sp
      @sp.set(Int32::MAX)
    else
      @sp.add(sp)
    end

    true
  end

  def remove_sp(sp : Int32) : Bool
    current_sp = sp()

    if current_sp < sp
      @sp.sub(current_sp)
    else
      @sp.sub(sp)
    end

    true
  end

  def get_exp_for_level(level : Int) : Int64
    ExperienceData.get_exp_for_level(level)
  end

  def run_speed : Float64
    if @active_char.inside_swamp_zone?
      if zone = ZoneManager.get_zone(@active_char, L2SwampZone)
        return super * zone.move_bonus
      end
    end

    super
  end

  def walk_speed : Float64
    if @active_char.inside_swamp_zone?
      if zone = ZoneManager.get_zone(@active_char, L2SwampZone)
        return super * zone.move_bonus
      end
    end

    super
  end

  def max_exp_level : Int32
    Config.max_player_level + 1
  end

  def max_level : Int32
    Config.max_player_level
  end

  def active_char : L2Playable
    super.as(L2Playable)
  end
end
