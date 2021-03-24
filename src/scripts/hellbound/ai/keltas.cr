class Scripts::Keltas < AbstractNpcAI
  # NPCs
  private KELTAS = 22341
  private ENFORCER = 22342
  private EXECUTIONER = 22343
  # Locations
  private ENFORCER_SPAWN_POINTS = {
    Location.new(-24540, 251404, -3320),
    Location.new(-24100, 252578, -3060),
    Location.new(-24607, 252443, -3074),
    Location.new(-23962, 252041, -3275),
    Location.new(-24381, 252132, -3090),
    Location.new(-23652, 251838, -3370),
    Location.new(-23838, 252603, -3095),
    Location.new(-23257, 251671, -3360),
    Location.new(-27127, 251106, -3523),
    Location.new(-27118, 251203, -3523),
    Location.new(-27052, 251205, -3523),
    Location.new(-26999, 250818, -3523),
    Location.new(-29613, 252888, -3523),
    Location.new(-29765, 253009, -3523),
    Location.new(-29594, 252570, -3523),
    Location.new(-29770, 252658, -3523),
    Location.new(-27816, 252008, -3527),
    Location.new(-27930, 252011, -3523),
    Location.new(-28702, 251986, -3523),
    Location.new(-27357, 251987, -3527),
    Location.new(-28859, 251081, -3527),
    Location.new(-28607, 250397, -3523),
    Location.new(-28801, 250462, -3523),
    Location.new(-29123, 250387, -3472),
    Location.new(-25376, 252368, -3257),
    Location.new(-25376, 252208, -3257)
  }
  private EXECUTIONER_SPAWN_POINTS = {
    Location.new(-24419, 251395, -3340),
    Location.new(-24912, 252160, -3310),
    Location.new(-25027, 251941, -3300),
    Location.new(-24127, 252657, -3058),
    Location.new(-25120, 252372, -3270),
    Location.new(-24456, 252651, -3060),
    Location.new(-24844, 251614, -3295),
    Location.new(-28675, 252008, -3523),
    Location.new(-27943, 251238, -3523),
    Location.new(-27827, 251984, -3523),
    Location.new(-27276, 251995, -3523),
    Location.new(-28769, 251955, -3523),
    Location.new(-27969, 251073, -3523),
    Location.new(-27233, 250938, -3523),
    Location.new(-26835, 250914, -3523),
    Location.new(-26802, 251276, -3523),
    Location.new(-29671, 252781, -3527),
    Location.new(-29536, 252831, -3523),
    Location.new(-29419, 253214, -3523),
    Location.new(-27923, 251965, -3523),
    Location.new(-28499, 251882, -3527),
    Location.new(-28194, 251915, -3523),
    Location.new(-28358, 251078, -3527),
    Location.new(-28580, 251071, -3527),
    Location.new(-28492, 250704, -3523)
  }
  # Misc
  @spawned_monsters = Set(L2Spawn).new
  @spawned_keltas : L2MonsterInstance?

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_kill_id(KELTAS)
    add_spawn_id(KELTAS)
  end

  private def spawn_minions
    ENFORCER_SPAWN_POINTS.each do |loc|
      minion = add_spawn(ENFORCER, loc, false, 0, false).as(L2MonsterInstance)
      sp = minion.spawn
      sp.respawn_delay = 60
      sp.amount = 1
      sp.start_respawn
      @spawned_monsters << sp
    end

    EXECUTIONER_SPAWN_POINTS.each do |loc|
      minion = add_spawn(EXECUTIONER, loc, false, 0, false).as(L2MonsterInstance)
      sp = minion.spawn
      sp.respawn_delay = 80
      sp.amount = 1
      sp.start_respawn
      @spawned_monsters << sp
    end
  end

  def on_adv_event(event, npc, player)
    if event.casecmp?("despawn")
      keltas = @spawned_keltas
      if keltas && keltas.alive?
        broadcast_npc_say(keltas, Say2::NPC_SHOUT, NpcString::THAT_IS_IT_FOR_TODAYLETS_RETREAT_EVERYONE_PULL_BACK)
        keltas.delete_me
        keltas.spawn.decrease_count(keltas)
        despawn_minions
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    cancel_quest_timers("despawn")
    despawn_minions

    super
  end

  def on_spawn(npc)
    @spawned_keltas = npc.as(L2MonsterInstance)
    broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::GUYS_SHOW_THEM_OUR_POWER)
    spawn_minions
    start_quest_timer("despawn", 1800000, nil, nil)

    super
  end

  private def despawn_minions
    return if @spawned_monsters.empty?
    @spawned_monsters.each do |sp|
      sp.stop_respawn
      minion = sp.last_spawn
      if minion && minion.alive?
        minion.delete_me
      end
    end
    @spawned_monsters.clear
  end
end
