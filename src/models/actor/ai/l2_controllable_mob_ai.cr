require "../../mob_group"

class L2ControllableMobAI < L2AttackableAI
  AI_IDLE = 1
  AI_NORMAL = 2
  AI_FORCEATTACK = 3
  AI_FOLLOW = 4
  AI_CAST = 5
  AI_ATTACK_GROUP = 6

  property alternate_ai : Int32 = 0
  property! group_target : MobGroup?
  property! forced_target : L2Character?
  property? thinking : Bool = false
  property? not_moving : Bool = false

  def initialize(creature : L2ControllableMobInstance)
    super
    self.alternate_ai = AI_IDLE
  end

  private def think_follow
    me = @actor.as(L2Attackable)

    unless Util.in_range?(MobGroupTable::FOLLOW_RANGE, me, forced_target, true)
      sx = Rnd.rand(2) == 0 ? -1 : 1
      sy = Rnd.rand(2) == 0 ? -1 : 1
      rx = Rnd.rand(MobGroupTable::FOLLOW_RANGE)
      ry = Rnd.rand(MobGroupTable::FOLLOW_RANGE)

      move_to(forced_target.x + (sx * rx), forced_target.y + (sy * ry), forced_target.z)
    end
  end

  private def on_event_think
    if thinking?
      return
    end

    self.thinking = true

    begin
      case alternate_ai
      when AI_IDLE
        unless intention.active?
          set_intention(ACTIVE)
        end
      when AI_FOLLOW
        think_follow
      when AI_CAST
        think_cast
      when AI_FORCEATTACK
        think_force_attack
      when AI_ATTACK_GROUP
        think_attack_group
      else
        if intention.active?
          think_active
        elsif intention.attack?
          think_attack
        end
      end
    ensure
      self.thinking = false
    end
  end

  private def think_cast
    npc = @actor.as(L2Attackable)
    attack_target = @attack_target
    if attack_target.nil? || attack_target.looks_dead?
      self.attack_target = find_next_rnd_target
      client_stop_moving(nil)
    end

    unless attack_target = @attack_target
      return
    end

    npc.target = attack_target

    unless @actor.muted?
      max_range = 0

      @actor.skills.each_value do |sk|
        if Util.in_range?(sk.cast_range, @actor, attack_target, true)
          unless @actor.skill_disabled?(sk)
            if @actor.current_mp > @actor.stat.get_mp_consume2(sk)
              @actor.do_cast(sk)
              return
            end
          end
        end

        max_range = Math.max(max_range, sk.cast_range)
      end

      unless not_moving?
        move_to_pawn(attack_target, max_range)
      end

      return
    end
  end

  private def think_attack_group
    target = forced_target?
    if target.nil? || target.looks_dead?
      # try to get next group target
      self.forced_target = find_next_group_target
      client_stop_moving(nil)
    end

    unless target.is_a?(L2ControllableMobInstance)
      return
    end

    @actor.target = target
    # as a response, we put the target in a forced attack mode
    target.ai.as(L2ControllableMobAI).force_attack(@actor)

    dist2 = @actor.calculate_distance(target, false, true)
    range = @actor.physical_attack_range + @actor.template.collision_radius + target.template.collision_radius
    max_range = range

    if !@actor.muted? && dist2 > (range + 20).abs2
      @actor.skills.each_value do |sk|
        cast_range = sk.cast_range

        if cast_range.abs2 >= dist2 && !@actor.skill_disabled?(sk) && @actor.current_mp > @actor.stat.get_mp_consume2(sk)
          @actor.do_cast(sk)
          return
        end

        max_range = Math.max(max_range, cast_range)
      end

      unless not_moving?
        move_to_pawn(target, range)
      end

      return
    end

    @actor.do_attack(target)
  end

  private def think_force_attack
    if forced_target?.nil? || forced_target.looks_dead?
      client_stop_moving(nil)
      set_intention(ACTIVE)
      self.alternate_ai = AI_IDLE
    end

    @actor.target = forced_target
    dist2 = @actor.calculate_distance(forced_target, false, true)
    range = @actor.physical_attack_range + @actor.template.collision_radius + forced_target.template.collision_radius
    max_range = range

    if !@actor.muted? && dist2 > (range + 20).abs2
      @actor.skills.each_value do |sk|
        cast_range = sk.cast_range

        if cast_range.abs2 >= dist2 && !@actor.skill_disabled?(sk) && @actor.current_mp > @actor.stat.get_mp_consume2(sk)
          @actor.do_cast(sk)
          return
        end

        max_range = Math.max(max_range, cast_range)
      end

      unless not_moving?
        move_to_pawn(forced_target, @actor.physical_attack_range)
      end

      return
    end

    @actor.do_attack(forced_target?)
  end

  private def think_attack
    attack_target = @attack_target
    if attack_target.nil? || attack_target.looks_dead?
      if attack_target
        # stop hating
        @actor.as(L2Attackable).stop_hating(attack_target)
      end

      set_intention(ACTIVE)
    else
      # notify aggression
      unless @actor.as(L2Npc).template.clans.empty?
        @actor.known_list.each_object do |npc|
          unless npc.is_a?(L2Npc)
            next
          end

          unless npc.in_my_clan?(@actor.as(L2Npc))
            next
          end

          if @actor.inside_radius?(npc, npc.template.clan_help_range, false, true) && (attack_target.z - npc.z).abs < 200
            npc.notify_event(AGGRESSION, attack_target, 1)
          end
        end
      end

      @actor.target = attack_target
      dist2 = @actor.calculate_distance(attack_target, false, true)
      range = @actor.physical_attack_range + @actor.template.collision_radius + attack_target.template.collision_radius
      max_range = range

      if !@actor.muted? && dist2 > (range + 20).abs2
        @actor.skills.each_value do |sk|
          cast_range = sk.cast_range

          if cast_range.abs2 >= dist2 && !@actor.skill_disabled?(sk) && @actor.current_mp > @actor.stat.get_mp_consume2(sk)
            @actor.do_cast(sk)
            return
          end

          max_range = Math.max(max_range, cast_range)
        end

        move_to_pawn(attack_target, range)
        return
      end

      # Force mobs to attack anybody if confused.

      if @actor.confused?
        hated = find_next_rnd_target
      else
        hated = attack_target
      end

      unless hated
        set_intention(ACTIVE)
        return
      end

      if hated != attack_target
        self.attack_target = hated
      end

      if !@actor.muted? && Rnd.rand(5) == 3
        @actor.skills.each_value do |sk|
          cast_range = sk.cast_range

          if cast_range.abs2 >= dist2 && !@actor.skill_disabled?(sk)
            if @actor.current_mp < @actor.stat.get_mp_consume2(sk)
              @actor.do_cast(sk)
              return
            end
          end
        end
      end

      @actor.do_attack(attack_target)
    end
  end

  private def think_active
    self.attack_target = find_next_rnd_target

    if @actor.confused?
      hated = find_next_rnd_target
    else
      hated = attack_target
    end

    if hated
      @actor.set_running
      set_intention(ATTACK, hated)
    end
  end

  private def check_auto_attack_condition(target : L2Character?) : Bool
    return false unless target

    if target.is_a?(L2NpcInstance) || target.is_a?(L2DoorInstance)
      return false
    end

    if target.npc?
      return false
    end

    if target.invul? || target.looks_dead?
      return false
    end

    if target.is_a?(L2PcInstance) && target.spawn_protected?
      return false
    end

    me = active_char
    unless me.inside_radius?(target, me.aggro_range, false, false)
      return false
    end

    unless (@actor.z - target.z).abs > 100
      return false
    end

    if target.is_a?(L2Playable) && target.silent_move_affected?
      return false
    end

    me.aggressive?
  end

  private def find_next_rnd_target : L2Character?
    targets = [] of L2Character
    @actor.known_list.each_character(active_char.aggro_range) do |char|
      if check_auto_attack_condition(char)
        targets << char
      end
    end

    targets.sample?(random: Rnd)
  end

  private def find_next_group_target : L2ControllableMobInstance?
    group_target.rand_mob
  end

  def force_attack(target)
    self.alternate_ai = AI_FORCEATTACK
    self.forced_target = target
  end

  def force_attack_group(group)
    self.forced_target = nil
    self.group_target = group
    self.alternate_ai = AI_ATTACK_GROUP
  end

  def stop
    self.alternate_ai = AI_IDLE
    client_stop_moving(nil)
  end

  def move(x : Int32, y : Int32, z : Int32)
    move_to(x, y, z)
  end

  def follow(target : L2Character)
    self.alternate_ai = AI_FOLLOW
    self.forced_target = target
  end
end
