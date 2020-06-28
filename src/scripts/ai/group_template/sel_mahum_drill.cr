class Scripts::SelMahumDrill < AbstractNpcAI
  class Actions < EnumClass
    getter social_action_id, alt_social_action_id, repeat_count, repeat_interval

    protected initializer social_action_id : Int32,
      alt_social_action_id : Int32, repeat_count : Int32,
      repeat_interval : Int32

    add(SCE_TRAINING_ACTION_A, 4, -1, 2, 2333)
    add(SCE_TRAINING_ACTION_B, 1, -1, 2, 4333)
    add(SCE_TRAINING_ACTION_C, 6,  5, 4, 1000)
    add(SCE_TRAINING_ACTION_D, 7, -1, 2, 1000)
  end

  private MAHUM_CHIEFS = {
    22775, # Sel Mahum Drill Sergeant
    22776, # Sel Mahum Training Officer
    22778  # Sel Mahum Drill Sergeant
  }

  private MAHUM_SOLDIERS = {
    22780, # Sel Mahum Recruit
    22782, # Sel Mahum Recruit
    22783, # Sel Mahum Soldier
    22784, # Sel Mahum Recruit
    22785  # Sel Mahum Soldier
  }

  private CHIEF_SOCIAL_ACTIONS = {
    1,
    4,
    5,
    7
  }

  private SOLDIER_SOCIAL_ACTIONS = {
    Actions::SCE_TRAINING_ACTION_A,
    Actions::SCE_TRAINING_ACTION_B,
    Actions::SCE_TRAINING_ACTION_C,
    Actions::SCE_TRAINING_ACTION_D
  }

  private CHIEF_FSTRINGS = {
    NpcString::HOW_DARE_YOU_ATTACK_MY_RECRUITS,
    NpcString::WHO_IS_DISRUPTING_THE_ORDER
  }

  private SOLDIER_FSTRINGS = {
    NpcString::THE_DRILLMASTER_IS_DEAD,
    NpcString::LINE_UP_THE_RANKS
  }

  # Chiefs event broadcast range
  private TRAINING_RANGE = 1000

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(MAHUM_SOLDIERS)
    add_kill_id(MAHUM_CHIEFS)
    add_event_received_id(MAHUM_CHIEFS)
    add_event_received_id(MAHUM_SOLDIERS)
    add_spawn_id(MAHUM_CHIEFS)
    add_spawn_id(MAHUM_SOLDIERS)
    # Start global return home timer
    start_quest_timer("return_home", 120000, nil, nil, true)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "do_social_action"
      if npc && npc.alive?
        if MAHUM_CHIEFS.includes?(npc.id)
          if npc.variables.get_i32("BUSY_STATE") == 0 && npc.intention.active? && npc.stays_in_spawn_loc?
            idx = Rnd.rand(6)
            if idx <= CHIEF_SOCIAL_ACTIONS.size &- 1
              npc.broadcast_social_action(CHIEF_SOCIAL_ACTIONS[idx])
              npc.variables["SOCIAL_ACTION_NEXT_INDEX"] = idx # Pass social action index to soldiers via script value
              npc.broadcast_event("do_social_action", TRAINING_RANGE, nil)
            end
          end

          start_quest_timer("do_social_action", 15_000, npc, nil)
        elsif MAHUM_SOLDIERS.includes?(npc.id)
          idx = npc.variables.get_i32("SOCIAL_ACTION_NEXT_INDEX")
          handle_social_action(npc, SOLDIER_SOCIAL_ACTIONS[idx], false)
        end
      end
    when "reset_busy_state"
      if npc
        npc.variables.delete("BUSY_STATE")
        npc.disable_core_ai(false)
      end
    when "return_home"
      MAHUM_SOLDIERS.each do |npc_id|
        SpawnTable.get_spawns(npc_id).each do |npc_spawn|
          soldier = npc_spawn.last_spawn
          if soldier && soldier.alive? && npc_spawn.name.try &.starts_with?("smtg_drill_group")
            unless soldier.stays_in_spawn_loc?
              if soldier.intention.active? || soldier.intention.idle?
                soldier.heading = npc_spawn.heading
                soldier.tele_to_location(npc_spawn.location, false)
              end
            end
          end
        end
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Rnd.rand(10) < 1
      npc.broadcast_event("ATTACKED", 1000, nil)
    end

    super
  end

  def on_event_received(event_name, sender, receiver, reference)
    if receiver && receiver.alive? && receiver.in_my_spawn_group?(sender)
      case event_name
      when "do_social_action"
        if MAHUM_SOLDIERS.includes?(receiver.id)
          action_idx = sender.variables.get_i32("SOCIAL_ACTION_NEXT_INDEX")
          receiver.variables["SOCIAL_ACTION_NEXT_INDEX"] = action_idx
          handle_social_action(receiver, SOLDIER_SOCIAL_ACTIONS[action_idx], true)
        end
      when "CHIEF_DIED"
        if MAHUM_SOLDIERS.includes?(receiver.id)
          if Rnd.rand(4) < 1
            broadcast_npc_say(receiver, Say2::NPC_ALL, SOLDIER_FSTRINGS.sample)
          end
          if receiver.can_be_attacked?
            receiver.as(L2Attackable).clear_aggro_list
          end
          receiver.disable_core_ai(true)
          receiver.variables["BUSY_STATE"] = 1
          receiver.running = true
          dst = Location.new(
            receiver.x + Rnd.rand(-800..800),
            receiver.y + Rnd.rand(-800..800),
            receiver.z,
            receiver.heading
          )
          receiver.set_intention(AI::MOVE_TO, dst)
          start_quest_timer("reset_busy_state", 5000, receiver, nil)
        end
      when "ATTACKED"
        if MAHUM_CHIEFS.includes?(receiver.id)
          broadcast_npc_say(receiver, Say2::NPC_ALL, CHIEF_FSTRINGS.sample)
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    npc.broadcast_event("CHIEF_DIED", TRAINING_RANGE, nil)
    nil
  end

  def on_spawn(npc)
    if MAHUM_CHIEFS.includes?(npc.id)
      start_quest_timer("do_social_action", 15000, npc, nil)
    elsif Rnd.rand(18) < 1 && MAHUM_SOLDIERS.includes?(npc.id)
      npc.variables["SOCIAL_ACTION_ALT_BEHAVIOR"] = 1
    end

    # Restore AI handling by core
    npc.disable_core_ai(false)
    super
  end

  private def handle_social_action(npc, action, first_call)
    if npc.variables.get_i32("BUSY_STATE") != 0 || !npc.intention.active? || !npc.stays_in_spawn_loc?
      return
    end

    if npc.variables.get_i32("SOCIAL_ACTION_ALT_BEHAVIOR") == 0
      social_action_id = action.social_action_id
    else
      social_action_id = action.alt_social_action_id
    end

    if social_action_id < 0
      return
    end

    if first_call
      npc.variables["SOCIAL_ACTION_REMAINED_COUNT"] = action.repeat_count
    end

    npc.broadcast_social_action(social_action_id)

    remain_count = npc.variables.get_i32("SOCIAL_ACTION_REMAINED_COUNT")
    if remain_count > 0
      npc.variables["SOCIAL_ACTION_REMAINED_COUNT"] = remain_count &- 1
      start_quest_timer("do_social_action", action.repeat_interval, npc, nil)
    end
  end
end
