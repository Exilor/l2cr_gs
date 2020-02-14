require "./self_analysis"

class L2FortSiegeGuardAI < L2CharacterAI
  private MAX_ATTACK_TIMEOUT = 300 # int ticks, i.e. 30 seconds

  @ai_task : Scheduler::PeriodicTask?
  @attack_range : Int32
  @thinking = false

  def initialize(creature : L2DefenderInstance)
    super(creature)

    @self_analysis = SelfAnalysis.new(creature)
    @self_analysis.init
    @attack_timeout = Int32::MAX
    @global_aggro = -10 # 10 seconds timeout of ATTACK after respawn
    @attack_range = @actor.physical_attack_range
  end

  def call
    on_event_think
  end

  private def auto_attack_condition(target)
    # Check if the target isn't another guard, folk or a door
    if target.nil? || target.is_a?(L2DefenderInstance) || target.is_a?(L2NpcInstance) || target.is_a?(L2DoorInstance) || target.looks_dead? || target.is_a?(L2FortCommanderInstance) || target.is_a?(L2Playable)
      if target.is_a?(L2PcInstance)
        pc = target
      elsif target.is_a?(L2Summon)
        pc = target.owner
      end

      return false unless pc

      if (clan = pc.clan) && clan.fort_id == @actor.as(L2Npc).fort.residence_id
        return false
      end
    end

    # Check if the target isn't invulnerable
    if target && target.invul?
      # However EffectInvincible requires to check GMs specially
      if target.player? && target.gm?
        return false
      end
      if target.is_a?(L2Summon) && target.owner.gm?
        return false
      end
    end

    # Get the owner if the target is a summon
    if target.is_a?(L2Summon)
      owner = target.owner
      if @actor.inside_radius?(owner, 1000, true, false)
        target = owner
      end
    end

    # Check if the target is a L2PcInstance
    if target.is_a?(L2Playable)
      # Check if the target isn't in silent move mode AND too far (>100)
      if target.silent_move_affected?
        unless @actor.inside_radius?(target, 250, false, false)
          return false
        end
      end
    end

    @actor.auto_attackable?(target) && GeoData.can_see_target?(@actor, target)
  end

  def change_intention(intention : Intention, arg0 : IntentionArgType = nil, arg1 : IntentionArgType = nil)
    sync do
      if intention.idle? # || intention.active? # active becomes idle if only a summon is present
        # Check if actor is not dead
        unless @actor.looks_dead?
          npc = @actor.as(L2Attackable)

          # If its _knownPlayer isn't empty set the Intention to ACTIVE
          if !npc.known_list.known_players.empty?
            intention = ACTIVE
          else
            intention = IDLE
          end
        end

        if intention.idle?
          # Set the Intention of this L2AttackableAI to IDLE
          super(IDLE)

          # Stop AI task and detach AI from NPC
          if task = @ai_task
            task.cancel
            @ai_task = nil
          end

          # Cancel the AI
          @actor.detach_ai

          return
        end
      end

      # Set the Intention of this L2AttackableAI to intention
      super(intention, arg0, arg1)

      # If not idle - create an AI task (schedule on_event_think repeatedly)
      @ai_task ||= ThreadPoolManager.schedule_ai_at_fixed_rate(self, 1000, 1000)
    end
  end

  private def on_intention_Attack(target)
    # Calculate the attack timeout
    @attack_timeout = MAX_ATTACK_TIMEOUT + GameTimer.ticks

    # Manage the Attack Intention : Stop current Attack (if necessary), Start a new Attack and Launch Think Event
    # if @actor.target != nil)
    super
  end

  private def think_active
    npc = @actor.as(L2Attackable)

    # Update every 1s the @global_aggro counter to come close to 0
    if @global_aggro != 0
      if @global_aggro < 0
        @global_aggro += 1
      else
        @global_aggro -= 1
      end
    end

    # Add all autoAttackable L2Character in L2Attackable Aggro Range to its _aggroList with 0 damage and 1 hate
    # A L2Attackable isn't aggressive during 10s after its spawn because @global_aggro is set to -10
    if @global_aggro >= 0
      npc.known_list.each_character(@attack_range) do |target|
        if auto_attack_condition(target) # check aggression
          # Get the hate level of the L2Attackable against this L2Character target contained in _aggroList
          hating = npc.get_hating(target)

          # Add the attacker to the L2Attackable _aggroList with 0 damage and 1 hate
          if hating == 0
            npc.add_damage_hate(target, 0, 1)
          end
        end
      end

      # Chose a target from its aggroList
      if @actor.confused?
        hated = attack_target? # Force mobs to attack anybody if confused
      else
        hated = npc.most_hated
        # _mostHatedAnalysis.Update(hated)
      end

      # Order to the L2Attackable to attack the target
      if hated
        # Get the hate level of the L2Attackable against this L2Character target contained in _aggroList
        aggro = npc.get_hating(hated)
        if aggro + @global_aggro > 0
          # Set the L2Character movement type to run and send Server->Client packet ChangeMoveType to all others L2PcInstance
          unless @actor.running?
            @actor.set_running
          end

          # Set the AI Intention to AI_INTENTION_ATTACK
          set_intention(ATTACK, hated)
        end

        return
      end

    end
    # Order to the L2SiegeGuardInstance to return to its home location because there's no target to attack
    if @actor.walk_speed >= 0
      if @actor.is_a?(L2DefenderInstance)
        @actor.as(L2DefenderInstance).return_home
      else
        @actor.as(L2FortCommanderInstance).return_home
      end
    end
  end

  private def think_attack
    if @attack_timeout < GameTimer.ticks
      # Check if the actor is running
      if @actor.running?
        # Set the actor movement type to walk and send Server->Client packet ChangeMoveType to all others L2PcInstance
        @actor.set_walking

        # Calculate a new attack timeout
        @attack_timeout = MAX_ATTACK_TIMEOUT + GameTimer.ticks
      end
    end

    att_tgt = attack_target?
    # Check if target is dead or if timeout is expired to stop this attack
    if att_tgt.nil? || att_tgt.looks_dead? || @attack_timeout < GameTimer.ticks
      # Stop hating this target after the attack timeout or if target is dead
      if att_tgt
        npc = @actor.as(L2Attackable)
        npc.stop_hating(att_tgt)
      end

      # Cancel target and timeout
      @attack_timeout = Int32::MAX
      self.attack_target = nil

      # Set the AI Intention to ACTIVE
      set_intention(ACTIVE)

      @actor.set_walking
      return
    end

    faction_notify_and_support
    attack_prepare
  end

  private def faction_notify_and_support
    target = attack_target?
    me = @actor.as(L2Npc)
    # Call all L2Object of its Faction inside the Faction Range
    if me.template.clans.empty? || target.nil?
      return
    end

    if target.invul?
      return # speeding it up for siege guards
    end

    # Go through all L2Character that belong to its faction
    # for (L2Character cha : @actor.known_list.each_character(((L2NpcInstance) @actor).getFactionRange+@actor.template.collisionRadius))
    me.known_list.each_character(1000) do |cha|
      unless cha.is_a?(L2Npc)
        if @self_analysis.has_heal_or_resurrect? && cha.is_a?(L2PcInstance) && me.fort.siege.defender?(cha.clan)
          # heal friends
          if !me.attacking_disabled? && cha.current_hp < cha.max_hp * 0.6 && me.current_hp > me.max_hp / 2 && me.current_mp > me.max_mp / 2 && cha.in_combat?
            @self_analysis.heal_skills.each do |sk|
              if me.current_mp < sk.mp_consume2
                next
              end
              if me.skill_disabled?(sk)
                next
              end
              unless Util.in_range?(sk.cast_range, me, cha, true)
                next
              end

              if 5 >= Rnd.rand(100)
                next
              end
              unless GeoData.can_see_target?(me, cha)
                break
              end

              old_target = me.target
              me.target = cha
              client_stop_moving(nil)
              me.do_cast(sk)
              me.target = old_target
              return
            end
          end
        end
        next
      end

      npc = cha.as(L2Npc)

      unless npc.in_my_clan?(@actor.as(L2Npc))
        next
      end

      if npc.ai?
        if npc.alive? && (target.z - npc.z).abs < 600
          if npc.ai.intention.idle? || npc.ai.intention.active?
            if target.inside_radius?(npc, 1500, true, false)
              if GeoData.can_see_target?(npc, target)
                npc.ai.notify_event(AGGRESSION, attack_target?, 1)
                return
              end
            end
          end
        end
        # heal friends
        if @self_analysis.has_heal_or_resurrect? && !@actor.attacking_disabled?
          if npc.hp_percent < 60
            if @actor.current_hp > @actor.max_hp // 2
              if @actor.current_mp > @actor.max_mp // 2 && npc.in_combat?
                @self_analysis.heal_skills.each do |sk|
                  if @actor.current_mp < sk.mp_consume2
                    next
                  end
                  if @actor.skill_disabled?(sk)
                    next
                  end
                  unless Util.in_range?(sk.cast_range, @actor, npc, true)
                    next
                  end

                  chance = 4
                  if chance >= Rnd.rand(100)
                    next
                  end
                  unless GeoData.can_see_target?(@actor, npc)
                    break
                  end

                  old_target = @actor.target
                  @actor.target = npc
                  client_stop_moving(nil)
                  @actor.do_cast(sk)
                  @actor.target = old_target
                  return
                end
              end
            end
          end
        end
      end
    end
  end

  private def attack_prepare
    # Get all information needed to choose between physical or magical attack
    dist_2 = 0.0
    range = 0
    if @actor.is_a?(L2FortCommanderInstance)
      s_guard = @actor.as(L2FortCommanderInstance)
    else
      s_guard = @actor.as(L2DefenderInstance)
    end

    unless att_tgt = attack_target?
      raise "Expected #{@actor} to have an attack target for #{self.class}#attack_prepare"
    end

    begin
      @actor.target = att_tgt
      skills = @actor.all_skills
      dist_2 = @actor.calculate_distance(att_tgt, false, true)
      range = @actor.physical_attack_range + @actor.template.collision_radius
      range += att_tgt.template.collision_radius
      if att_tgt.moving?
        range += 50
      end
    rescue e
      warn "Attack target is nil."
      warn e
      @actor.target = nil
      set_intention(IDLE)
      return
    end

    # never attack defenders
    if att_tgt.is_a?(L2PcInstance) && s_guard.fort.siege.defender?(att_tgt.clan)
      # Cancel the target
      s_guard.stop_hating(att_tgt)
      @actor.target = nil
      set_intention(IDLE)
      return
    end

    unless GeoData.can_see_target?(@actor, att_tgt)
      # Siege guards differ from normal mobs currently
      # If target cannot seen, don't attack any more
      s_guard.stop_hating(att_tgt)
      @actor.target = nil
      set_intention(IDLE)
      return
    end

    # Check if the actor isn't muted and if it is far from target
    if !@actor.muted? && dist_2 > range.abs2
      # check for ranged skills and heal/buff skills
      skills.each do |sk|
        cast_range = sk.cast_range

        if dist_2 <= cast_range.abs2 && cast_range > 70 && !@actor.skill_disabled?(sk) && @actor.current_mp >= @actor.stat.get_mp_consume2(sk) && !sk.passive?
          old_target = @actor.target
          if (sk.continuous? && !sk.debuff?) || sk.has_effect_type?(EffectType::HP)
            use_skill_self = true
            if sk.has_effect_type?(EffectType::HP)
              if @actor.current_hp > @actor.max_hp / 1.5
                use_skill_self = false
                break
              end
            end

            if (sk.continuous? && !sk.debuff?) && @actor.affected_by_skill?(sk.id)
              use_skill_self = false
            end

            if use_skill_self
              @actor.target = @actor
            end
          end

          client_stop_moving(nil)
          @actor.do_cast(sk)
          @actor.target = old_target
          return
        end
      end

      # Check if the L2SiegeGuardInstance is attacking, knows the target and can't run
      if !@actor.attacking_now? && @actor.run_speed == 0 && @actor.known_list.knows_object?(att_tgt)
        # Cancel the target
        @actor.known_list.remove_known_object(att_tgt)
        @actor.target = nil
        set_intention(IDLE)
      else
        dx = @actor.x.to_f - att_tgt.x
        dy = @actor.y.to_f - att_tgt.y
        dz = @actor.z.to_f - att_tgt.z
        home_x = att_tgt.x.to_f - s_guard.spawn.x
        home_y = att_tgt.y.to_f - s_guard.spawn.y

        # Check if the L2SiegeGuardInstance isn't too far from it's home location
        if dx.abs2 + dy.abs2 > 10000 && home_x.abs2 + home_y.abs2 > 3240000 && @actor.known_list.knows_object?(att_tgt)
          # Cancel the target
          @actor.known_list.remove_known_object(att_tgt)
          @actor.target = nil
          set_intention(IDLE)
        else
        # Move the actor to Pawn server side AND client side by sending Server->Client packet move_to_pawn (broadcast)
          # Temporary hack for preventing guards jumping off towers,
          # before replacing this with effective geodata checks and AI modification
          if dz.abs2 < 170.abs2 # normally 130 if guard z coordinates correct
            if @self_analysis.mage?
              range = @self_analysis.max_cast_range - 50
            end
            if @actor.walk_speed <= 0
              return
            end
            if att_tgt.moving?
              move_to_pawn(att_tgt, range - 70)
            else
              move_to_pawn(att_tgt, range)
            end
          end
        end
      end

      return
    # Else, if the actor is muted and far from target, just "move to pawn"
    elsif @actor.muted? && dist_2 > range.abs2
      # Temporary hack for preventing guards jumping off towers,
      # before replacing this with effective geodata checks and AI modification
      dz = @actor.z.to_f - att_tgt.z
      if dz.abs2 < 170.abs2 # normally 130 if guard z coordinates correct
        if @self_analysis.mage?
          range = @self_analysis.max_cast_range - 50
        end
        if @actor.walk_speed <= 0
          return
        end
        if att_tgt.moving?
          move_to_pawn(att_tgt, range - 70)
        else
          move_to_pawn(att_tgt, range)
        end
      end
      return
    # Else, if this is close enough to attack
    elsif dist_2 <= range.abs2
      # Force mobs to attack anybody if confused
      if @actor.confused?
        hated = att_tgt
      else
        hated = @actor.as(L2Attackable).most_hated
      end

      unless hated
        set_intention(ACTIVE)
        return
      end
      if hated != att_tgt
        att_tgt = hated
      end

      @attack_timeout = MAX_ATTACK_TIMEOUT + GameTimer.ticks

      # check for close combat skills && heal/buff skills
      if !@actor.muted? && Rnd.rand(100) <= 5
        skills.each do |sk|
          cast_range = sk.cast_range

          if cast_range.abs2 >= dist_2 && !sk.passive? && @actor.current_mp >= @actor.stat.get_mp_consume2(sk) && !@actor.skill_disabled?(sk)
            old_target = @actor.target
            if (sk.continuous? && !sk.debuff?) || sk.has_effect_type?(EffectType::HP)
              use_skill_self = true
              if sk.has_effect_type?(EffectType::HP) && @actor.current_hp > @actor.max_hp / 1.5
                use_skill_self = false
                break
              end

              if (sk.continuous? && !sk.debuff?) && @actor.affected_by_skill?(sk.id)
                use_skill_self = false
              end

              if use_skill_self
                @actor.target = @actor
              end
            end

            client_stop_moving(nil)
            @actor.do_cast(sk)
            @actor.target = old_target
            return
          end
        end
      end
      # Finally, do the physical attack itself
      @actor.do_attack(att_tgt)
    end
  end

  private def on_event_think
    # if(intention != AI_INTENTION_IDLE && (!@actor.isVisible || !@actor.hasAI || !@actor.isKnownPlayers))
    # set_intention(AI_INTENTION_IDLE)

    # Check if the actor can't use skills and if a thinking action isn't already in progress
    if @thinking || @actor.casting_now? || @actor.all_skills_disabled?
      return
    end

    # Start thinking action
    @thinking = true

    begin
      # Manage AI thinks of a L2Attackable
      if intention.active?
        think_active
      elsif intention.attack?
        think_attack
      end
    ensure
      # Stop thinking action
      @thinking = false
    end
  end

  private def on_event_attacked(attacker)
    # Calculate the attack timeout
    @attack_timeout = MAX_ATTACK_TIMEOUT + GameTimer.ticks

    # Set the @global_aggro to 0 to permit attack even just after spawn
    if @global_aggro < 0
      @global_aggro = 0
    end

    # Add the attacker to the _aggroList of the actor
    @actor.as(L2Attackable).add_damage_hate(attacker, 0, 1)

    # Set the L2Character movement type to run and send Server->Client packet ChangeMoveType to all others L2PcInstance
    unless @actor.running?
      @actor.set_running
    end

    # Set the Intention to AI_INTENTION_ATTACK
    unless intention.attack?
      set_intention(ATTACK, attacker)
    end

    super
  end

  private def on_event_aggression(target, aggro)
    if @actor.nil?
      return
    end
    me = @actor.as(L2Attackable)

    if target
      # Add the target to the actor _aggroList or update hate if already present
      me.add_damage_hate(target, 0, aggro)

      # Get the hate of the actor against the target
      aggro = me.get_hating(target)

      if aggro <= 0
        unless me.most_hated
          @global_aggro = -25
          me.clear_aggro_list
          set_intention(IDLE)
        end
        return
      end

      unless intention.attack?
        # Set the L2Character movement type to run and send Server->Client packet ChangeMoveType to all others L2PcInstance
        unless @actor.running?
          @actor.set_running
        end

        if @actor.is_a?(L2FortCommanderInstance)
          s_guard = @actor.as(L2FortCommanderInstance)
        else
          s_guard = @actor.as(L2DefenderInstance)
        end
        home_x = target.x.to_f - s_guard.spawn.x
        home_y = target.y.to_f - s_guard.spawn.y

        # Check if the L2SiegeGuardInstance is not too far from its home location
        if home_x.abs2 + home_y.abs2 < 3240000
          set_intention(ATTACK, target)
        end
      end
    else
      # currently only for setting lower general aggro
      if aggro >= 0
        return
      end

      unless most_hated = me.most_hated
        @global_aggro = -25
        return
      end

      me.aggro_list.each_key do |aggroed|
        me.add_damage_hate(aggroed, 0, aggro)
      end

      aggro = me.get_hating(most_hated)
      if aggro <= 0
        @global_aggro = -25
        me.clear_aggro_list
        set_intention(IDLE)
      end
    end
  end

  def stop_ai_task
    if task = @ai_task
      task.cancel
      @ai_task = nil
    end

    @actor.detach_ai

    super
  end
end
