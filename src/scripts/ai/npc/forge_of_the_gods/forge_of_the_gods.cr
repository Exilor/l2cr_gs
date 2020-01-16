class Scripts::ForgeOfTheGods < AbstractNpcAI
  # NPCs
  private FOG_MOBS = {
    22634, # Scarlet Stakato Worker
    22635, # Scarlet Stakato Soldier
    22636, # Scarlet Stakato Noble
    22637, # Tepra Scorpion
    22638, # Tepra Scarab
    22639, # Assassin Beetle
    22640, # Mercenary of Destruction
    22641, # Knight of Destruction
    22642, # Lavastone Golem
    22643, # Magma Golem
    22644, # Arimanes of Destruction
    22645, # Balor of Destruction
    22646, # Ashuras of Destruction
    22647, # Lavasillisk
    22648, # Blazing Ifrit
    22649  # Magma Drake
  }

  private LAVASAURI = {
    18799, # Newborn Lavasaurus
    18800, # Fledgling Lavasaurus
    18801, # Adult Lavasaurus
    18802, # Elderly Lavasaurus
    18803  # Ancient Lavasaurus
  }

  private REFRESH = 15

  private MOBCOUNT_BONUS_MIN = 3

  private BONUS_UPPER_LV01 = 5
  private BONUS_UPPER_LV02 = 10
  private BONUS_UPPER_LV03 = 15
  private BONUS_UPPER_LV04 = 20
  private BONUS_UPPER_LV05 = 35

  private BONUS_LOWER_LV01 = 5
  private BONUS_LOWER_LV02 = 10
  private BONUS_LOWER_LV03 = 15

  private FORGE_BONUS01 = 20
  private FORGE_BONUS02 = 40

  @npc_count = 0

  # _npcsAlive = 0; (L2J) TODO: Require zone spawn support

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_kill_id(FOG_MOBS)
    add_spawn_id(LAVASAURI)
    start_quest_timer("refresh", REFRESH * 1000, nil, nil, true)
  end

  def on_adv_event(event, npc, player)
    case event
    when "suicide"
      if npc
        npc.do_die(nil)
      end
    when "refresh"
      @npc_count = 0
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    rand = Rnd.rand(100)
    mob = nil
    @npc_count += 1

    # For monsters at Forge of the Gods - Lower level
    if npc.spawn.z < -5000 # && (_npcsAlive < 48))
      if @npc_count > BONUS_LOWER_LV03 && rand <= FORGE_BONUS02
        mob = add_spawn(LAVASAURI[4], npc, true)
      elsif @npc_count > BONUS_LOWER_LV02
        mob = spawn_lavasaurus(npc, rand, LAVASAURI[4], LAVASAURI[3])
      elsif @npc_count > BONUS_LOWER_LV01
        mob = spawn_lavasaurus(npc, rand, LAVASAURI[3], LAVASAURI[2])
      elsif @npc_count >= MOBCOUNT_BONUS_MIN
        mob = spawn_lavasaurus(npc, rand, LAVASAURI[2], LAVASAURI[1])
      end
    else
    # if _npcsAlive < 32)
      if @npc_count > BONUS_UPPER_LV05 && rand <= FORGE_BONUS02
        mob = add_spawn(LAVASAURI[1], npc, true)
      elsif @npc_count > BONUS_UPPER_LV04
        mob = spawn_lavasaurus(npc, rand, LAVASAURI[4], LAVASAURI[3])
      elsif @npc_count > BONUS_UPPER_LV03
        mob = spawn_lavasaurus(npc, rand, LAVASAURI[3], LAVASAURI[2])
      elsif @npc_count > BONUS_UPPER_LV02
        mob = spawn_lavasaurus(npc, rand, LAVASAURI[2], LAVASAURI[1])
      elsif @npc_count > BONUS_UPPER_LV01
        mob = spawn_lavasaurus(npc, rand, LAVASAURI[1], LAVASAURI[0])
      elsif @npc_count >= MOBCOUNT_BONUS_MIN && rand <= FORGE_BONUS01
        mob = add_spawn(LAVASAURI[0], npc, true)
      end
    end

    if mob
      mob.as(L2Attackable).add_damage_hate(killer, 0, 9999)
      mob.set_intention(AI::ATTACK, killer) # L2J doesn't give an attack target
    end

    super
  end

  def on_spawn(npc)
    start_quest_timer("suicide", 60000, npc, nil)
    super
  end

  private def spawn_lavasaurus(npc, rand, *mobs)
    # L2J checks that at least 2 mobs were provided but they always are.

    if rand <= FORGE_BONUS01
      add_spawn(mobs[0], npc, true)
    elsif rand <= FORGE_BONUS02
      add_spawn(mobs[1], npc, true)
    end
  end
end
