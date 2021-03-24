class Scripts::SelMahumSquad < AbstractNpcAI
  # NPC"s
  private CHEF  = 18908
  private FIRE  = 18927
  private STOVE = 18933

  private OHS_WEAPON = 15280
  private THS_WEAPON = 15281

  # Skills
  private SALMON_PORRIDGE_ATTACK = SkillHolder.new(6330)
  private CAMP_FIRE_TIRED        = SkillHolder.new(6331)
  private CAMP_FIRE_FULL         = SkillHolder.new(6332)
  private SOUP_OF_FAILURE        = SkillHolder.new(6688)

  # Sel Mahum Squad Leaders
  private SQUAD_LEADERS = {
    22786,
    22787,
    22788
  }

  private CHEF_FSTRINGS = {
    NpcString::I_BROUGHT_THE_FOOD,
    NpcString::COME_AND_EAT
  }

  private FIRE_EFFECT_BURN = 1
  private FIRE_EFFECT_NONE = 2

  private MAHUM_EFFECT_EAT   = 1
  private MAHUM_EFFECT_SLEEP = 2
  private MAHUM_EFFECT_NONE  = 3

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(CHEF)
    add_attack_id(SQUAD_LEADERS)
    add_event_received_id(CHEF, FIRE, STOVE)
    add_event_received_id(SQUAD_LEADERS)
    add_faction_call_id(SQUAD_LEADERS)
    add_kill_id(CHEF)
    add_move_finished_id(SQUAD_LEADERS)
    add_node_arrived_id(CHEF)
    add_skill_see_id(STOVE)
    add_spawn_id(CHEF, FIRE)
    add_spawn_id(SQUAD_LEADERS)
    add_spell_finished_id(CHEF)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "chef_disable_reward"
      npc.not_nil!.variables["REWARD_TIME_GONE"] = 1
    when "chef_heal_player"
      heal_player(npc.not_nil!, pc.not_nil!)
    when "chef_remove_invul"
      if npc.is_a?(L2MonsterInstance)
        npc.invul = false
        npc.variables.delete("INVUL_REMOVE_TIMER_STARTED")
        if pc && pc.alive? && npc.known_list.knows_player?(pc)
          add_attack_desire(npc, pc)
        end
      end
    when "chef_set_invul"
      if npc && npc.alive?
        npc.invul = true
      end
    when "fire"
      npc = npc.not_nil!
      start_quest_timer("fire", 30_000 &+ Rnd.rand(5000), npc, nil)
      npc.display_effect = FIRE_EFFECT_NONE

      if Rnd.rand(GameTimer.night? ? 2 : 4) < 1
        npc.display_effect = FIRE_EFFECT_BURN # fire burns
        npc.broadcast_event("SCE_CAMPFIRE_START", 600, nil)
      else
        npc.display_effect = FIRE_EFFECT_NONE # fire goes out
        npc.broadcast_event("SCE_CAMPFIRE_END", 600, nil)
      end
    when "fire_arrived"
      npc = npc.not_nil!
      # myself.i_quest0 = 1
      npc.running = false
      npc.target = npc

      if npc.no_random_walk?
        npc.do_cast(CAMP_FIRE_TIRED)
        npc.display_effect = MAHUM_EFFECT_SLEEP
      end
      if npc.variables.get_i32("BUSY_STATE") == 1 # Eatin
        npc.do_cast(CAMP_FIRE_FULL)
        npc.display_effect = MAHUM_EFFECT_EAT
      end

      start_quest_timer("remove_effects", 300_000, npc, nil)
    when "notify_dinner"
      npc = npc.not_nil!
      npc.broadcast_event("SCE_DINNER_EAT", 600, nil)
    when "remove_effects"
      npc = npc.not_nil!
      # myself.i_quest0 = 0
      npc.running = true
      npc.display_effect = MAHUM_EFFECT_NONE
    when "reset_full_bottle_prize"
      npc = npc.not_nil!
      npc.variables.delete("FULL_BARREL_REWARDING_PLAYER")
    when "return_from_fire"
      if npc.is_a?(L2MonsterInstance) && npc.alive?
        npc.return_home
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if npc.id == CHEF && npc.variables.get_i32("BUSY_STATE") == 0
      if npc.variables.get_i32("INVUL_REMOVE_TIMER_STARTED") == 0
        start_quest_timer("chef_remove_invul", 180_000, npc, attacker)
        start_quest_timer("chef_disable_reward", 60_000, npc, nil)
        npc.variables["INVUL_REMOVE_TIMER_STARTED"] = 1
      end
      start_quest_timer("chef_heal_player", 1000, npc, attacker)
      start_quest_timer("chef_set_invul", 60_000, npc, nil)
      npc.variables["BUSY_STATE"] = 1
    elsif SQUAD_LEADERS.includes?(npc.id)
      handle_pre_attack_motion(npc)
    end

    super
  end

  def on_faction_call(npc, caller, attacker, is_summon)
    handle_pre_attack_motion(npc)

    super
  end

  def on_event_received(event_name, sender, receiver, reference)
    case event_name
    when "SCE_DINNER_CHECK"
      if receiver.id == FIRE
        receiver.display_effect = FIRE_EFFECT_BURN
        stove = add_spawn(STOVE, receiver.x, receiver.y, receiver.z + 100, 0, false, 0)
        stove.summoner = receiver
        start_quest_timer("notify_dinner", 2000, receiver, nil) # @SCE_DINNER_EAT
        broadcast_npc_say(sender, Say2::NPC_ALL, CHEF_FSTRINGS.sample, 1250)
      end
    when "SCE_CAMPFIRE_START"
      if !receiver.no_random_walk? && receiver.alive? && !receiver.intention.attack? && SQUAD_LEADERS.includes?(receiver.id)
        receiver.no_random_walk = true # Moving to fire - i_ai0 = 1
        receiver.running = true
        loc = sender.get_point_in_range(100, 200)
        loc.heading = receiver.heading
        receiver.stop_move(nil)
        receiver.variables["DESTINATION_X"] = loc.x
        receiver.variables["DESTINATION_Y"] = loc.y
        receiver.set_intention(AI::MOVE_TO, loc)
      end
    when "SCE_CAMPFIRE_END"
      if receiver.id == STOVE && receiver.summoner == sender
        receiver.delete_me
      elsif !receiver.intention.attack? && SQUAD_LEADERS.includes?(receiver.id)
        receiver.no_random_walk = false
        receiver.variables.delete("BUSY_STATE")
        receiver.r_hand_id = THS_WEAPON
        start_quest_timer("return_from_fire", 3000, receiver, nil)
      end
    when "SCE_DINNER_EAT"
      if receiver.alive? && !receiver.intention.attack? && receiver.variables.get_i32("BUSY_STATE", 0) == 0 && SQUAD_LEADERS.includes?(receiver.id)
        if receiver.no_random_walk? # i_ai0 ==
          receiver.r_hand_id = THS_WEAPON
        end
        receiver.no_random_walk = true # Moving to fire - i_ai0 = 1
        receiver.variables["BUSY_STATE"] = 1 # Eating - i_ai3 = 1
        receiver.running = true
        broadcast_npc_say(
          receiver,
          Say2::NPC_ALL,
          Rnd.rand(3) < 1 ? NpcString::LOOKS_DELICIOUS : NpcString::LETS_GO_EAT
        )
        loc = sender.get_point_in_range(100, 200)
        loc.heading = receiver.heading
        receiver.stop_move(nil)
        receiver.variables["DESTINATION_X"] = loc.x
        receiver.variables["DESTINATION_Y"] = loc.y
        receiver.set_intention(AI::MOVE_TO, loc)
      end
    when "SCE_SOUP_FAILURE"
      if SQUAD_LEADERS.includes?(receiver.id)
        receiver.variables["FULL_BARREL_REWARDING_PLAYER"] = reference.not_nil!.l2id # TODO: Use it in 289 quest
        start_quest_timer("reset_full_bottle_prize", 180_000, receiver, nil)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.monster? && npc.variables.get_i32("REWARD_TIME_GONE") == 0
      npc.drop_item(killer, 15_492, 1)
    end

    cancel_quest_timer("chef_remove_invul", npc, nil)
    cancel_quest_timer("chef_disable_reward", npc, nil)
    cancel_quest_timer("chef_heal_player", npc, nil)
    cancel_quest_timer("chef_set_invul", npc, nil)

    super
  end

  def on_move_finished(npc)
    # Npc moves to fire
    if npc.no_random_walk? && npc.x == npc.variables.get_i32("DESTINATION_X")
      if npc.y == npc.variables.get_i32("DESTINATION_Y")
        npc.r_hand_id = OHS_WEAPON
        start_quest_timer("fire_arrived", 3000, npc, nil)
      end
    end
  end

  def on_node_arrived(npc)
    npc.broadcast_event("SCE_DINNER_CHECK", 300, nil)
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if npc.id == STOVE && skill.id == 9075 && targets.includes?(npc)
      npc.do_cast(SOUP_OF_FAILURE)
      npc.broadcast_event("SCE_SOUP_FAILURE", 600, caster)
    end

    super
  end

  def on_spawn(npc)
    if npc.id == CHEF
      npc.invul = false
    elsif npc.id == FIRE
      start_quest_timer("fire", 1000, npc, nil)
    elsif SQUAD_LEADERS.includes?(npc.id)
      npc.display_effect = 3
      npc.no_random_walk = false
    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    if skill && skill.id == 6330
      heal_player(npc, pc)
    end

    super
  end

  private def heal_player(npc, pc)
    if pc && pc.alive? && npc.variables.get_i32("INVUL_REMOVE_TIMER_STARTED") != 1 && (npc.intention.attack? || npc.intention.cast?)
      npc.target = pc
      npc.do_cast(SALMON_PORRIDGE_ATTACK)
    else
      cancel_quest_timer("chef_set_invul", npc, nil)
      npc.variables.delete("BUSY_STATE")
      npc.variables.delete("INVUL_REMOVE_TIMER_STARTED")
      npc.running = false
    end
  end

  private def handle_pre_attack_motion(attacked)
    cancel_quest_timer("remove_effects", attacked, nil)
    attacked.variables.delete("BUSY_STATE")
    attacked.no_random_walk = false
    attacked.display_effect = MAHUM_EFFECT_NONE
    if attacked.right_hand_item == OHS_WEAPON
      attacked.r_hand_id = THS_WEAPON
    end
    # TODO: Check about i_quest0
  end
end
