class Scripts::DarkWaterDragon < AbstractNpcAI
  private DRAGON = 22267
  private SHADE1 = 22268
  private SHADE2 = 22269
  private FAFURION = 18482
  private DETRACTOR1 = 22270
  private DETRACTOR2 = 22271
  private SECOND_SPAWN = Concurrent::Set(Int32).new # Used to track if second Shades were already spawned
  private TRACKING_SET = Concurrent::Set(Int32).new # Used to track instances of npcs
  private ID_MAP = Concurrent::Map(Int32, L2PcInstance).new # Used to track instances of npcs

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_kill_id(DRAGON, SHADE1, SHADE2, FAFURION, DETRACTOR1, DETRACTOR2)
    add_attack_id(DRAGON, SHADE1, SHADE2, FAFURION, DETRACTOR1, DETRACTOR2)
    add_spawn_id(DRAGON, SHADE1, SHADE2, FAFURION, DETRACTOR1, DETRACTOR2)
    TRACKING_SET.clear
    SECOND_SPAWN.clear
  end

  def on_adv_event(event, npc, pc)
    return super unless npc

    case event.casecmp
    when "first_spawn" # timer to start timer "1"
      start_quest_timer("1", 40000, npc, nil, true) # spawns detractor every 40 seconds
    when "second_spawn" # timer to start timer "2"
      start_quest_timer("2", 40000, npc, nil, true) # spawns detractor every 40 seconds
    when "third_spawn" # timer to start timer "3"
      start_quest_timer("3", 40000, npc, nil, true) # spawns detractor every 40 seconds
    when "fourth_spawn" # timer to start timer "4"
      start_quest_timer("4", 40000, npc, nil, true) # spawns detractor every 40 seconds
    when "1" # spawns a detractor
      add_spawn(DETRACTOR1, npc.x + 100, npc.y + 100, npc.z, 0, false, 40000)
    when "2" # spawns a detractor
      add_spawn(DETRACTOR2, npc.x + 100, npc.y - 100, npc.z, 0, false, 40000)
    when "3" # spawns a detractor
      add_spawn(DETRACTOR1, npc.x - 100, npc.y + 100, npc.z, 0, false, 40000)
    when "4" # spawns a detractor
      add_spawn(DETRACTOR2, npc.x - 100, npc.y - 100, npc.z, 0, false, 40000)
    when "fafurion_despawn" # Fafurion Kindred disappears and drops reward
      cancel_quest_timer("fafurion_poison", npc, nil)
      cancel_quest_timer("1", npc, nil)
      cancel_quest_timer("2", npc, nil)
      cancel_quest_timer("3", npc, nil)
      cancel_quest_timer("4", npc, nil)

      TRACKING_SET.delete(npc.l2id)

      if pc = ID_MAP.delete(npc.l2id)
        npc.as(L2Attackable).do_item_drop(NpcData[18485], pc)
      end

      npc.delete_me
    when "fafurion_poison" # Reduces Fafurions hp like it is poisoned
      if npc.current_hp <= 500
        cancel_quest_timer("fafurion_despawn", npc, nil)
        cancel_quest_timer("first_spawn", npc, nil)
        cancel_quest_timer("second_spawn", npc, nil)
        cancel_quest_timer("third_spawn", npc, nil)
        cancel_quest_timer("fourth_spawn", npc, nil)
        cancel_quest_timer("1", npc, nil)
        cancel_quest_timer("2", npc, nil)
        cancel_quest_timer("3", npc, nil)
        cancel_quest_timer("4", npc, nil)
        TRACKING_SET.delete(npc.l2id)
        ID_MAP.delete(npc.l2id)
      end
      npc.reduce_current_hp(500, npc, nil) # poison kills Fafurion if he is not healed
    else
      # [automatically added else]
    end


    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    npc_id = npc.id
    npc_l2id = npc.l2id
    if npc_id == DRAGON
      if TRACKING_SET.add?(npc_l2id) # this allows to handle multiple instances of npc
        # Spawn first 5 shades on first attack on Dark Water Dragon
        original_attacker = (is_summon ? attacker.summon : attacker) || attacker
        spawn_shade(original_attacker, SHADE1, npc.x + 100, npc.y + 100, npc.z)
        spawn_shade(original_attacker, SHADE2, npc.x + 100, npc.y - 100, npc.z)
        spawn_shade(original_attacker, SHADE1, npc.x - 100, npc.y + 100, npc.z)
        spawn_shade(original_attacker, SHADE2, npc.x - 100, npc.y - 100, npc.z)
        spawn_shade(original_attacker, SHADE1, npc.x - 150, npc.y + 150, npc.z)
      elsif npc.current_hp < npc.max_hp / 2 && SECOND_SPAWN.add?(npc_l2id)
        SECOND_SPAWN << npc_l2id
        # Spawn second 5 shades on half hp of on Dark Water Dragon
        original_attacker = (is_summon ? attacker.summon : attacker) || attacker
        spawn_shade(original_attacker, SHADE2, npc.x + 100, npc.y + 100, npc.z)
        spawn_shade(original_attacker, SHADE1, npc.x + 100, npc.y - 100, npc.z)
        spawn_shade(original_attacker, SHADE2, npc.x - 100, npc.y + 100, npc.z)
        spawn_shade(original_attacker, SHADE1, npc.x - 100, npc.y - 100, npc.z)
        spawn_shade(original_attacker, SHADE2, npc.x - 150, npc.y + 150, npc.z)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    npc_id = npc.id
    npc_l2id = npc.l2id
    if npc_id == DRAGON
      TRACKING_SET.delete(npc_l2id)
      SECOND_SPAWN.delete(npc_l2id)
      faf = add_spawn(FAFURION, *npc.xyz, 0, false, 0).as(L2Attackable) # spawns Fafurion Kindred when Dard Water Dragon is dead
      ID_MAP[faf.l2id] = killer
    elsif npc_id == FAFURION
      cancel_quest_timer("fafurion_poison", npc, nil)
      cancel_quest_timer("fafurion_despawn", npc, nil)
      cancel_quest_timer("first_spawn", npc, nil)
      cancel_quest_timer("second_spawn", npc, nil)
      cancel_quest_timer("third_spawn", npc, nil)
      cancel_quest_timer("fourth_spawn", npc, nil)
      cancel_quest_timer("1", npc, nil)
      cancel_quest_timer("2", npc, nil)
      cancel_quest_timer("3", npc, nil)
      cancel_quest_timer("4", npc, nil)
      TRACKING_SET.delete(npc_l2id)
      ID_MAP.delete(npc_l2id)
    end

    super
  end

  def on_spawn(npc)
    npc_id = npc.id
    npc_l2id = npc.l2id
    if npc_id == FAFURION
      unless TRACKING_SET.includes?(npc_l2id)
        TRACKING_SET << npc_l2id
        # Spawn 4 Detractors on spawn of Fafurion
        x = npc.x
        y = npc.y
        add_spawn(DETRACTOR2, x + 100, y + 100, npc.z, 0, false, 40000)
        add_spawn(DETRACTOR1, x + 100, y - 100, npc.z, 0, false, 40000)
        add_spawn(DETRACTOR2, x - 100, y + 100, npc.z, 0, false, 40000)
        add_spawn(DETRACTOR1, x - 100, y - 100, npc.z, 0, false, 40000)
        start_quest_timer("first_spawn", 2000, npc, nil) # timer to delay timer "1"
        start_quest_timer("second_spawn", 4000, npc, nil) # timer to delay timer "2"
        start_quest_timer("third_spawn", 8000, npc, nil) # timer to delay timer "3"
        start_quest_timer("fourth_spawn", 10000, npc, nil) # timer to delay timer "4"
        start_quest_timer("fafurion_poison", 3000, npc, nil, true) # Every three seconds reduces Fafurions hp like it is poisoned
        start_quest_timer("fafurion_despawn", 120000, npc, nil) # Fafurion Kindred disappears after two minutes
      end
    end

    super
  end

  def spawn_shade(attacker, npc_id, x, y, z)
    shade = add_spawn(npc_id, x, y, z, 0, false, 0)
    shade.set_running
    shade.as(L2Attackable).add_damage_hate(attacker, 0, 999)
    shade.set_intention(AI::ATTACK, attacker)
  end
end
