require "./l2_character_ai"

class L2AttackableAI < L2CharacterAI
  include Runnable

  class FearTask
    include Runnable

    initializer ai: L2AttackableAI, effector: L2Character, start: Bool

    def run
      @ai.fear_time -= FEAR_TICKS
      @ai.on_event_afraid(@effector, @start)
      @start = false
    end
  end

  private FEAR_TICKS = 5
  private RANDOM_WALK_RATE = 30
  private MAX_ATTACK_TIMEOUT = 1200

  @attack_timeout = Int32::MAX
  @time_pass = 0
  @chaos_time = 0
  @last_buff_tick = 0
  @thinking = false
  @ai_task : Runnable::PeriodicTask?
  @fear_task : Runnable::PeriodicTask?
  property fear_time : Int32 = 0
  property global_aggro : Int32 = -10

  def run
    on_event_think
  end

  ##############################################################################
  private def auto_attack_condition(target : L2Character?) : Bool
    return false unless target

    me = active_char

    # Check if the target isn't invulnerable
    if target.invul?
      # However EffectInvincible requires to check GMs specially
      if target.player? && target.gm?
        return false
      end
      if target.is_a?(L2Summon) && target.owner.gm?
        return false
      end
    end

    # Check if the target isn't a Folk or a Door
    if target.door?
      return false
    end

    # Check if the target isn't dead, is in the Aggro range and is at the same height
    if target.looks_dead? || (target.is_a?(L2Playable) && !me.inside_radius?(target, me.aggro_range, true, false))
      return false
    end

    # Check if the target is a L2Playable
    if target.is_a?(L2Playable)
      # Check if the AI isn't a Raid Boss, can See Silent Moving players and the target isn't in silent move mode
      if !me.raid? && !me.can_see_through_silent_move? && target.silent_move_affected?
        return false
      end
    end

    # Gets the player if there is any.
    player = target.acting_player?
    if player
      # Don't take the aggro if the GM has the access level below or equal to GM_DONT_TAKE_AGGRO
      if player.gm? && !player.access_level.can_take_aggro?
        debug "GM #{player.name} can't cause aggro."
        return false
      end

      # check if the target is within the grace period for JUST getting up from fake death
      if player.recent_fake_death?
        return false
      end

      if player.in_party? && player.party.in_dimensional_rift?
        rift_type = player.party.dimensional_rift.type
        rift_room = player.party.dimensional_rift.current_room

        if me.is_a?(L2RiftInvaderInstance) && !DimensionalRiftManager.get_room(rift_type, rift_room).in_zone?(*me.xyz)
          return false
        end
      end
    end

    # Check if the actor is a L2GuardInstance
    if me.is_a?(L2GuardInstance)
      # Check if the L2PcInstance target has karma (=PK)
      if player && player.karma > 0
        return GeoData.can_see_target?(me, player) # Los Check
      end
      # Check if the L2MonsterInstance target is aggressive
      if target.is_a?(L2MonsterInstance) && Config.guard_attack_aggro_mob
        return target.aggressive? && GeoData.can_see_target?(me, target)
      end

      return false
    elsif me.is_a?(L2FriendlyMobInstance)
      # Check if the target isn't another L2Npc
      if target.is_a?(L2Npc)
        return false
      end

      # Check if the L2PcInstance target has karma (=PK)
      if target.is_a?(L2PcInstance) && target.karma > 0
        return GeoData.can_see_target?(me, target) # Los Check
      end
      return false
    else
      if target.is_a?(L2Attackable)
        unless target.auto_attackable?(me)
          return false
        end

        if me.chaos? && me.inside_radius?(target, me.aggro_range, false, false)
          if target.in_my_clan?(me)
            return false
          end
          # Los Check
          return GeoData.can_see_target?(me, target)
        end
      end

      if target.is_a?(L2Attackable) || target.is_a?(L2Npc)
        return false
      end

      # depending on config, do not allow mobs to attack _new_ players in peacezones,
      # unless they are already following those players from outside the peacezone.
      if !Config.alt_mob_agro_in_peacezone && target.inside_peace_zone?
        return false
      end

      if me.champion? && Config.champion_passive
        return false
      end

      # Check if the actor is Aggressive
      me.aggressive? && GeoData.can_see_target?(me, target)
    end
  end

  def start_ai_task
    # If not idle - create an AI task (schedule onEvtThink repeatedly)
    @ai_task ||= ThreadPoolManager.schedule_ai_at_fixed_rate(self, 1000, 1000)
  end

  def stop_ai_task
    if task = @ai_task
      task.cancel
      @ai_task = nil
    end

    super
  end

  # Set the Intention of this L2CharacterAI and create an AI Task executed every 1s (call onEvtThink method) for this L2Attackable.<br>
  # <FONT COLOR=#FF0000><B> <U>Caution</U> : If actor _knowPlayer isn't EMPTY, IDLE will be change in ACTIVE</B></FONT>
  # @param intention The new Intention to set to the AI
  # @param arg0 The first parameter of the Intention
  # @param arg1 The second parameter of the Intention
  def change_intention(intention : Intention, arg0 = nil, arg1 = nil)
    # unless intention.move_to? || intention.active?
    #   debug "L2AttackableAI#change_intention(#{intention}, #{arg0}, #{arg1})"
    # end
    sync do
      if intention.idle? || intention.active?
        # Check if actor is not dead
        npc = active_char
        unless npc.looks_dead?
          # If its _knownPlayer isn't empty set the Intention to ACTIVE
          if !npc.known_list.known_players.empty?
            intention = ACTIVE
          else
            if npc.spawn?
              loc = npc.spawn.get_location(npc)
              range = Config.max_drift_range

              unless npc.inside_radius?(loc, range + range, true, false)
                intention = ACTIVE
              end
            end
          end
        end

        if intention.idle?
          # Set the Intention of this L2AttackableAI to IDLE
          super(IDLE)

          # Stop AI task and detach AI from NPC
          stop_ai_task

          # Cancel the AI
          @actor.detach_ai

          return
        end
      end

      # Set the Intention of this L2AttackableAI to intention
      super

      # If not idle - create an AI task (schedule onEvtThink repeatedly)
      start_ai_task
    end
  end

  # Manage the Attack Intention : Stop current Attack (if necessary), Calculate attack timeout, Start a new Attack and Launch Think Event.
  # @param target The L2Character to attack
  private def on_intention_attack(target)
    # debug "#L2AttackableAI#on_intention_attack(#{target})"
    # Calculate the attack timeout
    ticks = GameTimer.ticks
    @attack_timeout = MAX_ATTACK_TIMEOUT + ticks

    # self and buffs
    if @last_buff_tick + 30 < ticks
      active_char.template.get_ai_skills(AISkillScope::BUFF).each do |buff|
        if check_skill_cast_conditions(active_char, buff)
          unless @actor.affected_by_skill?(buff.id)
            @actor.target = @actor
            @actor.do_cast(buff)
            @actor.target = target
            break
          end
        end
      end

      @last_buff_tick = GameTimer.ticks
    end

    # Manage the Attack Intention : Stop current Attack (if necessary), Start a new Attack and Launch Think Event
    super
  end

  # protected so that the FearTask can call it.
  protected def on_event_afraid(effector : L2Character, start : Bool)
    if @fear_time > 0 && @fear_task.nil?
      @fear_task = ThreadPoolManager.schedule_ai_at_fixed_rate(FearTask.new(self, effector, start), 0, FEAR_TICKS * 1000)
      @actor.start_abnormal_visual_effect(true, {AbnormalVisualEffect::TURN_FLEE})
    else
      super

      if (@actor.dead? || @fear_time <= 0) && @fear_task
        @fear_task.try &.cancel
        @fear_task = nil
        @actor.stop_abnormal_visual_effect(true, {AbnormalVisualEffect::TURN_FLEE})
        set_intention(IDLE)
      end
    end
  end

  private def think_cast
    if check_target_lost(cast_target)
      self.cast_target = nil
      return
    end
    if maybe_move_to_pawn(cast_target, @actor.get_magical_attack_range(@skill))
      return
    end
    client_stop_moving
    set_intention(ACTIVE)
    @actor.do_cast(@skill.not_nil!)
  end

  # Manage AI standard thinks of a L2Attackable (called by onEvtThink). <B><U> Actions</U> :</B>
  # <ul>
  # <li>Update every 1s the @global_aggro counter to come close to 0</li>
  # <li>If the actor is Aggressive and can attack, add all autoAttackable L2Character in its Aggro Range to its _aggroList, chose a target and order to attack it</li>
  # <li>If the actor is a L2GuardInstance that can't attack, order to it to return to its home location</li>
  # <li>If the actor is a L2MonsterInstance that can't attack, order to it to random walk (1/100)</li>
  # </ul>
  private def think_active
    npc = active_char

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
      # Get all visible objects inside its Aggro Range
      npc.known_list.known_objects.each_value do |obj|
        if !obj.is_a?(L2Character) || obj.is_a?(L2StaticObjectInstance)
          next
        end

        target = obj

        # Check to see if this is a festival mob spawn. If it is, then check to see if the aggro trigger is a festival participant...if so, move to attack it.
        if npc.is_a?(L2FestivalMonsterInstance) && obj.is_a?(L2PcInstance)
          target_player = obj

          unless target_player.festival_participant?
            next
          end
        end

        # For each L2Character check if the target is autoattackable
        if auto_attack_condition(target) # check aggression
          if target.is_a?(L2Playable)
            evt = OnAttackableHate.new(active_char, target.acting_player, target.is_a?(L2Summon))
            term = EventDispatcher.notify(evt, active_char, TerminateReturn)
            if term
              debug "There's a TerminateReturn."
            end
            if term && term.terminate
              debug "TerminateReturn of OnAttackableHate returned true."
              next
            end
          end

          # Get the hate level of the L2Attackable against this target contained in _aggroList
          hating = npc.get_hating(target)

          # Add the attacker to the L2Attackable _aggroList with 0 damage and 1 hate
          if hating == 0
            npc.add_damage_hate(target, 0, 0i64)
          end
        end
      end

      # Chose a target from its aggroList
      if npc.confused?
        hated = attack_target? # effect handles selection
      else
        hated = npc.most_hated
      end

      # Order to the L2Attackable to attack the target
      if hated && !npc.core_ai_disabled?
        # Get the hate level of the L2Attackable against this target contained in _aggroList
        aggro = npc.get_hating(hated)
        if aggro + @global_aggro > 0
          # Set the L2Character movement type to run and send Server->Client packet ChangeMoveType to all others L2PcInstance
          unless npc.running?
            npc.set_running
          end

          # Set the AI Intention to ATTACK
          set_intention(ATTACK, hated)
        end

        return
      end
    end

    # Chance to forget attackers after some time
    if npc.current_hp == npc.max_hp && npc.current_mp == npc.max_mp && !npc.attack_by_list.empty? && Rnd.rand(500) == 0
      npc.clear_aggro_list
      npc.attack_by_list.clear
      if npc.is_a?(L2MonsterInstance)
        if npc.has_minions?
          npc.minion_list.delete_reused_minions
        end
      end
    end

    # Check if the mob should not return to spawn point
    unless npc.can_return_to_spawn_point?
      return
    end

    # Check if the actor is a L2GuardInstance
    if npc.is_a?(L2GuardInstance) && !npc.walker?
      # Order to the L2GuardInstance to return to its home location because there's no target to attack
      npc.return_home
    end

    # If this is a festival monster, then it remains in the same location.
    if npc.is_a?(L2FestivalMonsterInstance)
      return
    end

    # Minions following leader
    leader = npc.leader?
    if leader && !leader.looks_dead?
      min_radius = 30

      if npc.raid_minion?
        offset = 500 # for Raids - need correction
      else
        offset = 200 # for normal minions - need correction :)
      end

      if leader.running?
        npc.set_running
      else
        npc.set_walking
      end

      if npc.calculate_distance(leader, false, true) > offset.abs2
        x1 = Rnd.rand(min_radius * 2..offset * 2) # x
        y1 = Rnd.rand(x1..offset * 2) # distance
        y1 = Math.sqrt((y1 * y1) - (x1 * x1)).to_i32 # y
        if x1 > offset + min_radius
          x1 = (leader.x + x1) - offset
        else
          x1 = (leader.x - x1) + min_radius
        end
        if y1 > offset + min_radius
          y1 = (leader.y + y1) - offset
        else
          y1 = (leader.y - y1) + min_radius
        end

        z1 = leader.z
        # Move the actor to Location (x,y,z) server side AND client side by sending Server->Client packet CharMoveToLocation (broadcast)
        move_to(x1, y1, z1)
        return
      elsif Rnd.rand(RANDOM_WALK_RATE) == 0
        npc.template.get_ai_skills(AISkillScope::BUFF).each do |sk|
          if cast(sk)
            return
          end
        end
      end
    # Order to the L2MonsterInstance to random walk (1/100)
    elsif npc.spawn? && Rnd.rand(RANDOM_WALK_RATE) == 0 && !npc.no_rnd_walk?
      x1 = 0
      y1 = 0
      z1 = 0
      range = Config.max_drift_range

      npc.template.get_ai_skills(AISkillScope::BUFF).each do |sk|
        if cast(sk)
          return
        end
      end

      # If NPC with random coord in territory - old method (for backward compatibility)
      if npc.spawn.x == 0 && npc.spawn.y == 0 && npc.spawn.spawn_territory.nil?
        # Calculate a destination point in the spawn area
        location = TerritoryTable.get_random_point(npc.spawn.location_id)
        if location
          x1 = location.x
          y1 = location.y
          z1 = location.z
        end

        # Calculate the distance between the current position of the L2Character and the target (x,y)
        distance2 = npc.calculate_distance(x1, y1, 0, false, true)

        if distance2 > (range + range) * (range + range)
          npc.returning_to_spawn_point = true
          delay = Math.sqrt(distance2).to_f32 / range
          x1 = npc.x + ((x1 - npc.x) / delay).to_i32
          y1 = npc.y + ((y1 - npc.y) / delay).to_i32
        end

        # If NPC with random fixed coord, don't move (unless needs to return to spawnpoint)
        if !npc.returning_to_spawn_point? && TerritoryTable.get_proc_max(npc.spawn.location_id) > 0
          return
        end
      else
        x1 = npc.spawn.get_x(npc)
        y1 = npc.spawn.get_y(npc)
        z1 = npc.spawn.get_z(npc)

        if !npc.inside_radius?(x1, y1, 0, range, false, false)
          npc.returning_to_spawn_point = true
        else
          delta_x = Rnd.rand(range * 2) # x
          delta_y = Rnd.rand(delta_x..range * 2) # distance
          delta_y = Math.sqrt((delta_y * delta_y) - (delta_x * delta_x)).to_i32 # y
          x1 = (delta_x + x1) - range
          y1 = (delta_y + y1) - range
          z1 = npc.z
        end
      end
      # Move the actor to Location (x,y,z) server side AND client side by sending Server->Client packet CharMoveToLocation (broadcast)
      loc = GeoData.move_check(*npc.xyz, x1, y1, z1, npc.instance_id)

      move_to(*loc.xyz)
    end
  end

   # Manage AI attack thinks of a L2Attackable (called by onEvtThink).<br>
   # <b><u>Actions</u>:</b>
   # <ul>
   # <li>Update the attack timeout if actor is running</li>
   # <li>If target is dead or timeout is expired, stop this attack and set the Intention to ACTIVE</li>
   # <li>Call all L2Object of its Faction inside the Faction Range</li>
   # <li>Chose a target and order to attack it with magic skill or physical attack</li>
   # </ul>
  private def think_attack
    npc = active_char
    if npc.casting_now?
      return
    end

    if npc.core_ai_disabled?
      return
    end

    most_hate = npc.most_hated
    unless most_hate
      set_intention(ACTIVE)
      return
    end

    self.attack_target = most_hate
    npc.target = most_hate

    # Immobilize condition
    if npc.movement_disabled?
      movement_disable
      return
    end

    # Check if target is dead or if timeout is expired to stop this attack
    original_attack_target = attack_target?
    if original_attack_target.nil? || original_attack_target.looks_dead? || @attack_timeout < GameTimer.ticks
      # Stop hating this target after the attack timeout or if target is dead
      npc.stop_hating(original_attack_target)

      # Set the AI Intention to ACTIVE
      set_intention(ACTIVE)

      npc.set_walking
      return
    end

    original_attack_target = original_attack_target.not_nil!

    collision = npc.template.collision_radius

    # Handle all L2Object of its Faction inside the Faction Range

    clans = active_char.template.clans
    if clans && !clans.empty?
      faction_range = npc.template.clan_help_range + collision
      # Go through all L2Object that belong to its faction
      begin
        npc.known_list.each_character(faction_range) do |obj|
          if obj.is_a?(L2Npc)
            called = obj

            unless active_char.template.clan?(called.template.clans)
              next
            end

            # Check if the L2Object is inside the Faction Range of the actor
            if called.ai?
              if ((original_attack_target.z - called.z).abs < 600) && npc.attack_by_list.includes?(original_attack_target) && ((called.ai.intention == IDLE) || (called.ai.intention == ACTIVE)) && (called.instance_id == npc.instance_id)
                if original_attack_target.is_a?(L2Playable)
                  if original_attack_target.in_party? && original_attack_target.party.in_dimensional_rift?
                    rift_type = original_attack_target.party.dimensional_rift.type
                    rift_room = original_attack_target.party.dimensional_rift.current_room

                    if npc.is_a?(L2RiftInvaderInstance) && !DimensionalRiftManager.get_room(rift_type, rift_room).in_zone?(*npc.xyz)
                      next
                    end
                  end

                  # By default, when a faction member calls for help, attack the caller's attacker.
                  # Notify the AI with EVT_AGGRESSION
                  called.notify_event(AGGRESSION, original_attack_target, 1)
                  EventDispatcher.notify(OnAttackableFactionCall.new(called, active_char, original_attack_target.acting_player, original_attack_target.is_a?(L2Summon)), called)
                elsif called.is_a?(L2Attackable) && attack_target? && !called.intention.attack? != ATTACK
                  called.add_damage_hate(attack_target, 0, npc.get_hating(attack_target))
                  called.set_intention(ATTACK, attack_target)
                end
              end
            end
          end
        end
      rescue e
        error e
      end
    end

    # Initialize data
    combined_collision = collision + most_hate.template.collision_radius

    ai_suicide_skills = npc.template.get_ai_skills(AISkillScope::SUICIDE)
    if !ai_suicide_skills.empty? && (npc.current_hp / npc.max_hp) * 100 < 30
      skill = ai_suicide_skills.sample(random: Rnd)
      if Util.in_range?(skill.affect_range, active_char, most_hate, false) && npc.has_skill_chance?
        if cast(skill)
          return
        end
      end
    end

    # ------------------------------------------------------
    # In case many mobs are trying to hit from same place, move a bit, circling around the target
    # Note from Gnacik:
    # On l2js because of that sometimes mobs don't attack player only running
    # around player without any sense, so decrease chance for now
    if !npc.movement_disabled? && Rnd.rand(100) <= 3
      npc.known_list.known_objects.each_value do |nearby|
        if nearby.is_a?(L2Attackable) && npc.inside_radius?(nearby, collision, false, false) && nearby != most_hate
          new_x = combined_collision + Rnd.rand(40)
          if Rnd.bool
            new_x = most_hate.x + new_x
          else
            new_x = most_hate.x - new_x
          end
          new_y = combined_collision + Rnd.rand(40)
          if Rnd.bool
            new_y = most_hate.y + new_y
          else
            new_y = most_hate.y - new_y
          end

          unless npc.inside_radius?(new_x, new_y, 0, collision, false, false)
            new_z = npc.z + 30
            if GeoData.can_move?(*npc.xyz, new_x, new_y, new_z, npc.instance_id)
              move_to(new_x, new_y, new_z)
            end
          end
          return
        end
      end
    end
    # Dodge if its needed
    if !npc.movement_disabled? && npc.dodge > 0
      if Rnd.rand(100) <= npc.dodge
        # Micht: Keeping this one otherwise we should do 2 sqrt
        distance2 = npc.calculate_distance(most_hate, false, true)
        if Math.sqrt(distance2) <= 60 + combined_collision
          pos_x = npc.x
          pos_y = npc.y
          pos_z = npc.z + 30

          if original_attack_target.x < pos_x
            pos_x = pos_x + 300
          else
            pos_x = pos_x - 300
          end

          if original_attack_target.y < pos_y
            pos_y = pos_y + 300
          else
            pos_y = pos_y - 300
          end

          if GeoData.can_move?(*npc.xyz, pos_x, pos_y, pos_z, npc.instance_id)
            set_intention(MOVE_TO, Location.new(pos_x, pos_y, pos_z, 0))
          end

          return
        end
      end
    end

    # BOSS/Raid Minion Target Reconsider
    if npc.raid? || npc.raid_minion?
      @chaos_time += 1
      if npc.is_a?(L2RaidBossInstance)
        if !npc.has_minions?
          if @chaos_time > Config.raid_chaos_time
            if Rnd.rand(100) <= 100 - ((npc.current_hp * 100) / npc.max_hp)
              aggro_reconsider
              @chaos_time = 0
              return
            end
          end
        else
          if @chaos_time > Config.raid_chaos_time
            if Rnd.rand(100) <= 100 - ((npc.current_hp * 200) / npc.max_hp)
              aggro_reconsider
              @chaos_time = 0
              return
            end
          end
        end
      elsif npc.is_a?(L2GrandBossInstance)
        if @chaos_time > Config.grand_chaos_time
          chaos_rate = 100 - ((npc.current_hp * 300) / npc.max_hp)
          if ((chaos_rate <= 10) && (rand(100) <= 10)) || ((chaos_rate > 10) && (rand(100) <= chaos_rate))
            aggro_reconsider
            @chaos_time = 0
            return
          end
        end
      else
        if @chaos_time > Config.minion_chaos_time
          if Rnd.rand(100) <= 100 - ((npc.current_hp * 200) / npc.max_hp)
            aggro_reconsider
            @chaos_time = 0
            return
          end
        end
      end
    end

    general_skills = npc.template.get_ai_skills(AISkillScope::GENERAL)
    unless general_skills.empty?
      # Heal Condition
      ai_heal_skills = npc.template.get_ai_skills(AISkillScope::HEAL)
      unless ai_heal_skills.empty?
        percentage = (npc.current_hp / npc.max_hp) * 100
        if npc.minion?
          leader = npc.leader?
          if leader && !leader.dead? && Rnd.rand(100) > (leader.current_hp / leader.max_hp) * 100
            ai_heal_skills.each do |heal_skill|
              if heal_skill.target_type.self?
                next
              end

              unless check_skill_cast_conditions(npc, heal_skill)
                next
              end

              if !Util.in_range?((heal_skill.cast_range + collision + leader.template.collision_radius), npc, leader, false) && !party?(heal_skill) && !npc.movement_disabled?
                move_to_pawn(leader, heal_skill.cast_range + collision + leader.template.collision_radius)
                return
              end

              if GeoData.can_see_target?(npc, leader)
                client_stop_moving
                target = npc.target
                npc.target = leader
                npc.do_cast(heal_skill)
                npc.target = target
                return
              end
            end
          end
        end

        if Rnd.rand(100) < (100 - percentage) / 3
          ai_heal_skills.each do |sk|
            unless check_skill_cast_conditions(npc, sk)
              next
            end

            client_stop_moving
            target = npc.target
            npc.target = npc
            npc.do_cast(sk)
            npc.target = target
            return
          end
        end

        ai_heal_skills.each do |sk|
          unless check_skill_cast_conditions(npc, sk)
            next
          end

          if sk.target_type.one?
            npc.known_list.each_character(sk.cast_range + collision) do |obj|
              unless obj.is_a?(L2Attackable) && obj.alive?
                next
              end

              targets = obj
              unless targets.in_my_clan?(npc)
                next
              end

              percentage = (targets.current_hp / targets.max_hp) * 100
              if Rnd.rand(100) < (100 - percentage) / 10
                if GeoData.can_see_target?(npc, targets)
                  client_stop_moving
                  target = npc.target
                  npc.target = obj
                  npc.do_cast(sk)
                  npc.target = target
                  return
                end
              end
            end
          end

          if party?(sk)
            client_stop_moving
            npc.do_cast(sk)
            return
          end
        end
      end

      # Res Skill Condition
      ai_res_skill = npc.template.get_ai_skills(AISkillScope::RES)
      unless ai_res_skill.empty?
        if npc.minion?
          leader = npc.leader?
          if leader && leader.dead?
            ai_res_skill.each do |sk|
              if sk.target_type.self?
                next
              end

              unless check_skill_cast_conditions(npc, sk)
                next
              end

              if !Util.in_range?((sk.cast_range + collision + leader.template.collision_radius), npc, leader, false) && !party?(sk) && !npc.movement_disabled?
                move_to_pawn(leader, sk.cast_range + collision + leader.template.collision_radius)
                return
              end

              if GeoData.can_see_target?(npc, leader)
                client_stop_moving
                target = npc.target
                npc.target = leader
                npc.do_cast(sk)
                npc.target = target
                return
              end
            end
          end
        end

        ai_res_skill.each do |sk|
          unless check_skill_cast_conditions(npc, sk)
            next
          end
          if sk.target_type.one?
            npc.known_list.each_character(sk.cast_range + collision) do |obj|
              unless obj.is_a?(L2Attackable) && obj.dead?
                next
              end

              targets = (obj.as(L2Attackable))
              unless npc.in_my_clan?(targets)
                next
              end
              if Rnd.rand(100) < 10
                if GeoData.can_see_target?(npc, targets)
                  client_stop_moving
                  target = npc.target
                  npc.target = obj
                  npc.do_cast(sk)
                  npc.target = target
                  return
                end
              end
            end
          end

          if party?(sk)
            client_stop_moving
            target = npc.target
            npc.target = npc
            npc.do_cast(sk)
            npc.target = target
            return
          end
        end
      end
    end

    dist = npc.calculate_distance(most_hate, false, false)
    dist2 = (dist - collision).to_i32
    range = npc.physical_attack_range + combined_collision
    if most_hate.moving?
      range = range + 50
      if npc.moving?
        range = range + 50
      end
    end

    # Long/Short Range skill usage.
    if !npc.short_range_skills.empty? && npc.has_skill_chance?
      short_range_skill = npc.short_range_skills.sample(random: Rnd)
      if check_skill_cast_conditions(npc, short_range_skill)
        client_stop_moving
        npc.do_cast(short_range_skill)
        return
      end
    end

    if !npc.long_range_skills.empty? && npc.has_skill_chance?
      long_range_skill = npc.long_range_skills.sample(random: Rnd)
      if check_skill_cast_conditions(npc, long_range_skill)
        client_stop_moving
        npc.do_cast(long_range_skill)
        return
      end
    end

    # Starts melee attack
    if dist2 > range || !GeoData.can_see_target?(npc, most_hate)
      # debug "dist > range: #{dist > range}, !GeoData.can_see_target?(npc, most_hate): #{!GeoData.can_see_target?(npc, most_hate)}"
      if npc.movement_disabled?
        target_reconsider
      else
        target = attack_target?
        if target
          if target.moving?
            range -= 100
          end
          move_to_pawn(target, Math.max(range, 5))
        end
      end
      return
    end

    # Attacks target
    @actor.do_attack(attack_target?)
  end

  private def cast(sk : Skill?)
    return false unless sk

    caster = active_char
    unless check_skill_cast_conditions(caster, sk)
      return false
    end

    unless attack_target?
      if caster.most_hated
        self.attack_target = caster.most_hated
      end
    end

    attack_target = attack_target?
    unless attack_target
      return false
    end

    dist = caster.calculate_distance(attack_target, false, false)
    dist2 = dist - attack_target.template.collision_radius
    range = caster.physical_attack_range + caster.template.collision_radius + attack_target.template.collision_radius
    srange = sk.cast_range + caster.template.collision_radius
    if attack_target.moving?
      dist2 = dist2 - 30
    end

    if sk.continuous?
      if !sk.debuff?
        unless caster.affected_by_skill?(sk.id)
          client_stop_moving
          caster.target = caster
          caster.do_cast(sk)
          @actor.target = attack_target
          return true
        end
        # If actor already have buff, start looking at others same faction mob to cast
        if sk.target_type.self?
          return false
        end
        if sk.target_type.one?
          target = effect_target_reconsider(sk, true)
          if target
            client_stop_moving
            caster.target = target
            caster.do_cast(sk)
            caster.target = attack_target
            return true
          end
        end
        if can_party?(sk)
          client_stop_moving
          caster.target = caster
          caster.do_cast(sk)
          caster.target = attack_target
          return true
        end
      else
        if GeoData.can_see_target?(caster, attack_target) && !can_aoe?(sk) && !attack_target.dead? && dist2 <= srange
          unless attack_target.affected_by_skill?(sk.id)
            client_stop_moving
            caster.do_cast(sk)
            return true
          end
        elsif can_aoe?(sk)
          if sk.target_type.aura? || sk.target_type.behind_aura? || sk.target_type.front_aura? || sk.target_type.aura_corpse_mob? || sk.target_type.aura_undead_enemy?
            client_stop_moving
            caster.do_cast(sk)
            return true
          end
          if (sk.target_type.area? || sk.target_type.behind_area? || sk.target_type.front_area?) && GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
            client_stop_moving
            caster.do_cast(sk)
            return true
          end
        elsif sk.target_type.one?
          target = effect_target_reconsider(sk, false)
          if target
            client_stop_moving
            caster.do_cast(sk)
            return true
          end
        end
      end
    end

    if sk.has_effect_type?(L2EffectType::DISPEL)
      if sk.target_type.one?
        if attack_target.effect_list.get_first_effect(L2EffectType::BUFF) && GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
        target = effect_target_reconsider(sk, false)
        if target
          client_stop_moving
          caster.target = target
          caster.do_cast(sk)
          caster.target = attack_target
          return true
        end
      elsif can_aoe?(sk)
        if (sk.target_type.aura? || sk.target_type.behind_aura? || sk.target_type.front_aura?) && GeoData.can_see_target?(caster, attack_target)

          client_stop_moving
          caster.do_cast(sk)
          return true
        elsif (sk.target_type.area? || sk.target_type.behind_area? || sk.target_type.front_area?) && GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      end
    end

    if sk.has_effect_type?(L2EffectType::HP)
      percentage = (caster.current_hp / caster.max_hp) * 100
      if caster.minion? && !sk.target_type.self? != L2TargetType::SELF
        leader = caster.leader?
        if leader && !leader.dead? && Rnd.rand(100) > (leader.current_hp / leader.max_hp) * 100
          if !Util.in_range?((sk.cast_range + caster.template.collision_radius + leader.template.collision_radius), caster, leader, false) && !party?(sk) && !caster.movement_disabled?
            move_to_pawn(leader, sk.cast_range + caster.template.collision_radius + leader.template.collision_radius)
          end
          if GeoData.can_see_target?(caster, leader)
            client_stop_moving
            caster.target = leader
            caster.do_cast(sk)
            caster.target = attack_target
            return true
          end
        end
      end

      if Rnd.rand(100) < (100 - percentage) / 3
        client_stop_moving
        caster.target = caster
        caster.do_cast(sk)
        caster.target = attack_target
        return true
      end

      if sk.target_type.one?
        caster.known_list.each_character(sk.cast_range + caster.template.collision_radius) do |obj|
          unless obj.is_a?(L2Attackable) && obj.alive?
            next
          end

          targets = obj
          unless caster.in_my_clan?(targets)
            next
          end

          percentage = (targets.current_hp / targets.max_hp) * 100
          if Rnd.rand(100) < (100 - percentage) / 10
            if GeoData.can_see_target?(caster, targets)
              client_stop_moving
              caster.target = obj
              caster.do_cast(sk)
              caster.target = attack_target
              return true
            end
          end
        end
      end
      if party?(sk)
        caster.known_list.each_character(sk.affect_range + caster.template.collision_radius) do |obj|
          unless obj.is_a?(L2Attackable)
            next
          end

          targets = obj
          if targets.in_my_clan?(caster)
            if obj.current_hp < obj.max_hp && Rnd.rand(100) <= 20
              client_stop_moving
              caster.target = caster
              caster.do_cast(sk)
              caster.target = attack_target
              return true
            end
          end
        end
      end
    end

    if sk.has_effect_type?(L2EffectType::PHYSICAL_ATTACK, L2EffectType::MAGICAL_ATTACK, L2EffectType::HP_DRAIN)
      if !can_aura?(sk)
        if GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
          client_stop_moving
          caster.do_cast(sk)
          return true
        end

        target = skill_target_reconsider(sk)
        if target
          client_stop_moving
          caster.target = target
          caster.do_cast(sk)
          caster.target = attack_target
          return true
        end
      else
        client_stop_moving
        caster.do_cast(sk)
        return true
      end
    end

    if sk.has_effect_type?(L2EffectType::SLEEP)
      if sk.target_type.one?
        if !attack_target.dead? && dist2 <= srange
          if dist2 > range || attack_target.moving?
            unless attack_target.affected_by_skill?(sk.id)
              client_stop_moving
              caster.do_cast(sk)
              return true
            end
          end
        end

        target = effect_target_reconsider(sk, false)
        if target
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      elsif can_aoe?(sk)
        if sk.target_type.aura? || sk.target_type.behind_aura? || sk.target_type.front_aura?
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
        if (sk.target_type.area? || sk.target_type.behind_area? || sk.target_type.front_area?) && GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      end
    end

    if sk.has_effect_type?(L2EffectType::STUN, L2EffectType::ROOT, L2EffectType::PARALYZE, L2EffectType::MUTE, L2EffectType::FEAR)
      if GeoData.can_see_target?(caster, attack_target) && !can_aoe?(sk) && dist2 <= srange
        unless attack_target.affected_by_skill?(sk.id)
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      elsif can_aoe?(sk)
        if sk.target_type.aura? || sk.target_type.behind_aura? || sk.target_type.front_aura?
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
        if (sk.target_type.area? || sk.target_type.behind_area? || sk.target_type.front_area?) && GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      elsif sk.target_type.one?
        target = effect_target_reconsider(sk, false)
        if target
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      end
    end

    if sk.has_effect_type?(L2EffectType::DMG_OVER_TIME)
      if GeoData.can_see_target?(caster, attack_target) && !can_aoe?(sk) && !attack_target.dead? && dist2 <= srange
        unless attack_target.affected_by_skill?(sk.id)
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      elsif can_aoe?(sk)
        if sk.target_type.aura? || sk.target_type.behind_aura? || sk.target_type.front_aura? || sk.target_type.aura_corpse_mob? || sk.target_type.aura_undead_enemy?
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
        if (sk.target_type.area? || sk.target_type.behind_area? || sk.target_type.front_area?) && GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      elsif sk.target_type.one?
        target = effect_target_reconsider(sk, false)
        if target
          client_stop_moving
          caster.do_cast(sk)
          return true
        end
      end
    end

    if sk.has_effect_type?(L2EffectType::RESURRECTION)
      if !party?(sk)
        if caster.minion? && !sk.target_type.self?
          leader = caster.leader?
          if leader
            if leader.dead?
              if !Util.in_range?((sk.cast_range + caster.template.collision_radius + leader.template.collision_radius), caster, leader, false) && !party?(sk) && !caster.movement_disabled?
                move_to_pawn(leader, sk.cast_range + caster.template.collision_radius + leader.template.collision_radius)
              end
            end
            if GeoData.can_see_target?(caster, leader)
              client_stop_moving
              caster.target = leader
              caster.do_cast(sk)
              caster.target = attack_target
              return true
            end
          end
        end

        caster.known_list.each_character(sk.cast_range + caster.template.collision_radius) do |obj|
          unless obj.is_a?(L2Attackable) && obj.dead?
            next
          end

          targets = obj
          unless caster.in_my_clan?(targets)
            next
          end

          if Rnd.rand(100) < 10
            if GeoData.can_see_target?(caster, targets)
              client_stop_moving
              caster.target = obj
              caster.do_cast(sk)
              caster.target = attack_target
              return true
            end
          end
        end
      elsif party?(sk)
        caster.known_list.each_character(sk.affect_range + caster.template.collision_radius) do |obj|
          unless obj.is_a?(L2Attackable)
            next
          end
          targets = obj
          if caster.in_my_clan?(targets)
            if obj.current_hp < obj.max_hp && Rnd.rand(100) <= 20
              client_stop_moving
              caster.target = caster
              caster.do_cast(sk)
              caster.target = attack_target
              return true
            end
          end
        end
      end
    end

    if !can_aura?(sk)
      if GeoData.can_see_target?(caster, attack_target) && !attack_target.dead? && dist2 <= srange
        client_stop_moving
        caster.do_cast(sk)
        return true
      end

      target = skill_target_reconsider(sk)
      if target
        client_stop_moving
        caster.target = target
        caster.do_cast(sk)
        caster.target = attack_target
        return true
      end
    else
      client_stop_moving
      caster.do_cast(sk)
      return true
    end

    false
  end

  private def movement_disable
    npc = active_char
    return unless target = attack_target?

    npc.target ||= target

    dist = npc.calculate_distance(target, false, false)
    range = npc.physical_attack_range + npc.template.collision_radius + target.template.collision_radius
    # TODO(Zoey76): Review this "magic changes".
    random = Rnd.rand(100)
    if !target.immobilized? && random < 15
      if try_cast(npc, target, AISkillScope::IMMOBILIZE, dist)
        return
      end
    end

    if random < 20
      if try_cast(npc, target, AISkillScope::COT, dist)
        return
      end
    end

    if random < 30
      if try_cast(npc, target, AISkillScope::DEBUFF, dist)
        return
      end
    end

    if random < 40
      if try_cast(npc, target, AISkillScope::NEGATIVE, dist)
        return
      end
    end

    if npc.movement_disabled? || npc.ai_type.mage? || npc.ai_type.healer?
      if try_cast(npc, target, AISkillScope::ATTACK, dist)
        return
      end
    end

    if try_cast(npc, target, AISkillScope::UNIVERSAL, dist)
      return
    end

    # If cannot cast, try to attack.
    if dist <= range && GeoData.can_see_target?(npc, target)
      @actor.do_attack(target)
      return
    end

    # If cannot cast nor attack, find a new target.
    target_reconsider
  end

  private def try_cast(npc : L2Attackable, target : L2Character, scope : AISkillScope, dist : Float64) : Bool
    npc.template.get_ai_skills(scope).each do |sk|
      if !check_skill_cast_conditions(npc, sk) || (((sk.cast_range + target.template.collision_radius) <= dist) && !can_aura?(sk))
        next
      end

      unless GeoData.can_see_target?(npc, target)
        next
      end

      client_stop_moving
      npc.do_cast(sk)
      return true
    end

    false
  end

  # @param caster the caster
  # @param skill the skill to check.
  private def check_skill_cast_conditions(caster : L2Attackable, skill : Skill) : Bool
    if caster.casting_now? && !skill.simultaneous_cast?
      return false
    end
    # Not enough MP.
    if skill.mp_consume2 >= caster.current_mp
      return false
    end
    # Character is in "skill disabled" mode.
    if caster.skill_disabled?(skill)
      return false
    end
    # If is a static skill and magic skill and character is muted or is a physical skill muted and character is physically muted.
    if !skill.static? && ((skill.magic? && caster.muted?) || caster.physical_muted?)
      return false
    end

    true
  end

  private def effect_target_reconsider(sk : Skill?, positive : Bool) : L2Character?
    return unless sk
    unless attack_target?
      warn "No attack_target for effect_target_reconsider."
    end
    actor = active_char
    if !sk.has_effect_type?(L2EffectType::DISPEL)
      if !positive
        dist = 0.0
        dist2 = 0.0
        range = 0

        actor.attack_by_list.each do |obj|
          if obj.nil? || obj.dead? || !GeoData.can_see_target?(actor, obj) || obj == attack_target?
            next
          end
          begin
            actor.target = attack_target
            dist = actor.calculate_distance(obj, false, false)
            dist2 = dist - actor.template.collision_radius
            range = sk.cast_range + actor.template.collision_radius + obj.template.collision_radius
            if obj.moving?
              dist2 = dist2 - 70
            end
          rescue e
            error e
            next
          end
          if dist2 <= range
            unless attack_target.affected_by_skill?(sk.id)
              return obj
            end
          end
        end

        # If there is nearby Target with aggro, start going on random target that is attackable
        actor.known_list.each_character(range) do |obj|
          if obj.dead? || !GeoData.can_see_target?(actor, obj)
            next
          end
          begin
            actor.target = attack_target
            dist = actor.calculate_distance(obj, false, false)
            dist2 = dist
            range = sk.cast_range + actor.template.collision_radius + obj.template.collision_radius
            if obj.moving?
              dist2 = dist2 - 70
            end
          rescue e
            error e
            next
          end

          if obj.is_a?(L2PcInstance) || obj.is_a?(L2Summon)
            if dist2 <= range
              unless attack_target.affected_by_skill?(sk.id)
                return obj
              end
            end
          end
        end
      elsif positive
        dist = 0.0
        dist2 = 0.0
        range = 0
        actor.known_list.each_character(range) do |obj|
          unless obj.is_a?(L2Attackable)
            next
          end

          if obj.dead?
            next
          end

          unless GeoData.can_see_target?(actor, obj)
            next
          end

          targets = obj
          if targets.in_my_clan?(actor)
            next
          end

          begin
            actor.target = attack_target
            dist = actor.calculate_distance(obj, false, false)
            dist2 = dist - actor.template.collision_radius
            range = sk.cast_range + actor.template.collision_radius + obj.template.collision_radius
            if obj.moving?
              dist2 = dist2 - 70
            end
          rescue e
            error e
            next
          end
          if dist2 <= range
            unless obj.affected_by_skill?(sk.id)
              return obj
            end
          end
        end
      end
    else
      dist = 0.0
      dist2 = 0.0
      range = 0
      range = sk.cast_range + actor.template.collision_radius + attack_target.template.collision_radius
      actor.known_list.each_character(range) do |obj|
        if obj.nil? || obj.dead? || !GeoData.can_see_target?(actor, obj)
          next
        end
        begin
          actor.target = attack_target
          dist = actor.calculate_distance(obj, false, false)
          dist2 = dist - actor.template.collision_radius
          range = sk.cast_range + actor.template.collision_radius + obj.template.collision_radius
          if obj.moving?
            dist2 = dist2 - 70
          end
        rescue e
          error e
          next
        end

        if obj.is_a?(L2PcInstance) || obj.is_a?(L2Summon)

          if dist2 <= range
            if attack_target.effect_list.get_first_effect(L2EffectType::BUFF)
              return obj
            end
          end
        end
      end
    end

    nil
  end

  private def skill_target_reconsider(sk : Skill) : L2Character?
    unless attack_target?
      warn "No attack_target for skill_target_reconsider."
    end
    dist = 0.0
    dist2 = 0.0
    range = 0
    actor = active_char
    if actor.hate_list?
      actor.hate_list.each do |obj|
        if !GeoData.can_see_target?(actor, obj) || obj.dead?
          next
        end
        begin
          actor.target = attack_target
          dist = actor.calculate_distance(obj, false, false)
          dist2 = dist - actor.template.collision_radius
          range = sk.cast_range + actor.template.collision_radius + attack_target.template.collision_radius
          # if(obj.moving?)
          # dist2 = dist2 - 40
        rescue e
          error e
          next
        end
        if dist2 <= range
          return obj
        end
      end
    end

    unless actor.is_a?(L2GuardInstance)
      actor.known_list.known_objects.each_value do |target|
        begin
          actor.target = attack_target
          dist = actor.calculate_distance(target, false, false)
          dist2 = dist
          range = sk.cast_range + actor.template.collision_radius + attack_target.template.collision_radius
          # if(obj.moving?)
          # dist2 = dist2 - 40
        rescue e
          error e
          next
        end
        obj = nil
        if target.is_a?(L2Character)
          obj = target
        end
        if obj.nil? || !GeoData.can_see_target?(actor, obj) || dist2 > range
          next
        end
        if obj.is_a?(L2PcInstance)
          return obj
        end
        if obj.is_a?(L2Attackable)
          if actor.chaos?
            if obj.in_my_clan?(actor)
              next
            end

            return obj
          end
        end
        if obj.is_a?(L2Summon)
          return obj
        end
      end
    end

    nil
  end

  private def target_reconsider
    dist = 0.0
    dist2 = 0.0
    range = 0
    actor = active_char
    most_hate = actor.most_hated
    if actor.hate_list?
      actor.hate_list.each do |obj|
        if !GeoData.can_see_target?(actor, obj) || obj.dead? || obj != most_hate || obj == actor
          next
        end
        begin
          dist = actor.calculate_distance(obj, false, false)
          dist2 = dist - actor.template.collision_radius
          range = actor.physical_attack_range + actor.template.collision_radius + obj.template.collision_radius
          if obj.moving?
            dist2 = dist2 - 70
          end
        rescue e
          error e
          next
        end

        if dist2 <= range
          if most_hate
            actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
          else
            actor.add_damage_hate(obj, 0, 2000i64)
          end
          actor.target = obj
          self.attack_target = obj
          return
        end
      end
    end
    unless actor.is_a?(L2GuardInstance)
      actor.known_list.known_objects.each_value do |target|
        next unless obj = target.as?(L2Character)

        if !GeoData.can_see_target?(actor, obj) || obj.dead? || obj != most_hate || obj == actor || obj == attack_target
          next
        end
        if obj.is_a?(L2PcInstance)
          if most_hate
            actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
          else
            actor.add_damage_hate(obj, 0, 2000i64)
          end
          actor.target = obj
          self.attack_target = obj
        elsif obj.is_a?(L2Attackable)
          if actor.chaos?
            if obj.in_my_clan?(actor)
              next
            end

            if most_hate
              actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
            else
              actor.add_damage_hate(obj, 0, 2000i64)
            end
            actor.target = obj
            self.attack_target = obj
          end
        elsif obj.is_a?(L2Summon)
          if most_hate
            actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
          else
            actor.add_damage_hate(obj, 0, 2000i64)
          end
          actor.target = obj
          self.attack_target = obj
        end
      end
    end
  end

  private def aggro_reconsider
    actor = active_char
    most_hate = actor.most_hated
    if actor.hate_list?
      rand = Rnd.rand(actor.hate_list.size)
      count = 0
      actor.hate_list.each do |obj|
        if count < Rnd.rand
          count += 1
          next
        end

        if !GeoData.can_see_target?(actor, obj) || obj.dead? || obj == attack_target? || obj == actor
          next
        end

        begin
          actor.target = attack_target?
        rescue e
          error e
          next
        end
        if most_hate
          actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
        else
          actor.add_damage_hate(obj, 0, 2000i64)
        end
        actor.target = obj
        self.attack_target = obj
        return
      end
    end

    unless actor.is_a?(L2GuardInstance)
      actor.known_list.known_objects.each_value do |target|
        unless obj = target.as?(L2Character)
          next
        end

        if !GeoData.can_see_target?(actor, obj) || obj.dead? || obj != most_hate || obj == actor
          next
        end
        if obj.is_a?(L2PcInstance)
          if most_hate && most_hate.alive?
            actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
          else
            actor.add_damage_hate(obj, 0, 2000i64)
          end
          actor.target = obj
          self.attack_target = obj
        elsif obj.is_a?(L2Attackable)
          if actor.chaos?
            if obj.in_my_clan?(actor)
              next
            end

            if most_hate
              actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
            else
              actor.add_damage_hate(obj, 0, 2000i64)
            end
            actor.target = obj
            self.attack_target = obj
          end
        elsif obj.is_a?(L2Summon)
          if most_hate
            actor.add_damage_hate(obj, 0, actor.get_hating(most_hate))
          else
            actor.add_damage_hate(obj, 0, 2000i64)
          end
          actor.target = obj
          self.attack_target = obj
        end
      end
    end
  end

  # Manage AI thinking actions of a L2Attackable.
  private def on_event_think
    # Check if the actor can't use skills and if a thinking action isn't already in progress
    if @thinking || active_char.all_skills_disabled?
      return
    end

    # Start thinking action
    @thinking = true

    begin
      # Manage AI thinks of a L2Attackable
      case intention
      when ACTIVE
        think_active
      when ATTACK
        think_attack
      when CAST
        think_cast
      end
    rescue e
      error e
    ensure
      # Stop thinking action
      @thinking = false
    end
  end

  # Launch actions corresponding to the Event Attacked.<br>
  # <B><U> Actions</U> :</B>
  # <ul>
  # <li>Init the attack : Calculate the attack timeout, Set the @global_aggro to 0, Add the attacker to the actor _aggroList</li>
  # <li>Set the L2Character movement type to run and send Server->Client packet ChangeMoveType to all others L2PcInstance</li>
  # <li>Set the Intention to ATTACK</li>
  # </ul>
  # @param attacker The L2Character that attacks the actor
  private def on_event_attacked(attacker : L2Character)
    me = active_char

    # Calculate the attack timeout
    @attack_timeout = MAX_ATTACK_TIMEOUT + GameTimer.ticks

    # Set the @global_aggro to 0 to permit attack even just after spawn
    if @global_aggro < 0
      @global_aggro = 0
    end

    # Add the attacker to the _aggroList of the actor
    me.add_damage_hate(attacker, 0, 1i64)

    # Set the L2Character movement type to run and send Server->Client packet ChangeMoveType to all others L2PcInstance
    unless me.running?
      me.set_running
    end

    # Set the Intention to ATTACK
    if !intention.attack?
      set_intention(ATTACK, attacker)
    elsif me.most_hated != attack_target?
      set_intention(ATTACK, attacker)
    end

    if me.is_a?(L2MonsterInstance)
      master = me

      if master.has_minions?
        master.minion_list.on_assist(me, attacker)
      end

      master = master.leader?
      if master && master.has_minions?
        master.minion_list.on_assist(me, attacker)
      end
    end

    super
  end

   # Launch actions corresponding to the Event Aggression.<br>
   # <B><U> Actions</U> :</B>
   # <ul>
   # <li>Add the target to the actor _aggroList or update hate if already present</li>
   # <li>Set the actor Intention to ATTACK (if actor is L2GuardInstance check if it isn't too far from its home location)</li>
   # </ul>
   # @param aggro The value of hate to add to the actor against the target
  private def on_event_aggression(target, long aggro)
    me = active_char
    if me.dead?
      return
    end

    if target
      # Add the target to the actor _aggroList or update hate if already present
      me.add_damage_hate(target, 0, aggro.to_i64)

      # Set the actor AI Intention to ATTACK
      if !intention.attack?
        # Set the L2Character movement type to run and send Server->Client packet ChangeMoveType to all others L2PcInstance
        unless me.running?
          me.set_running
        end

        set_intention(ATTACK, target)
      end

      if me.is_a?(L2MonsterInstance)
        master = me

        if master.has_minions?
          master.minion_list.on_assist(me, target)
        end

        master = master.leader?
        if master && master.has_minions?
          master.minion_list.on_assist(me, target)
        end
      end
    end
  end

  private def on_intention_active
    # Cancel attack timeout
    @attack_timeout = Int32::MAX
    super
  end

  def active_char
    @actor.as(L2Attackable)
  end
end
