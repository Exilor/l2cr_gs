class NpcAI::AltarsOfSacrifice < AbstractNpcAI
  private class Altar
    include Loggable

    @spawned_boss : L2Npc?
    @boss_npc_ids : Indexable(Int32) = Slice(Int32).empty

    initializer middle_point: Locatable

    def initialize(@middle_point : Locatable, *@boss_npc_ids : Int32)
    end

    def spawn_boss
      if !has_bosses? || @spawned_boss
        raise "illegal state"
      end

      spawn = L2Spawn.new(@boss_npc_ids.sample(Rnd))
      spawn.amount = 1
      spawn.heading = Rnd.u16.to_i32

      radius = Rnd.rand(BOSS_MIN_SPAWN_RADIUS..BOSS_MAX_SPAWN_RADIUS)
      angle_radians = Rnd.rand * 2 * Math::PI
      spawn_x = ((radius * Math.cos(angle_radians)) + @middle_point.x).to_i
      spawn_y = ((radius * Math.sin(angle_radians)) + @middle_point.y).to_i
      spawn_z = GeoData.get_height(spawn_x, spawn_y, @middle_point.z)
      spawn.set_xyz(spawn_x, spawn_y, spawn_z)
      spawn.stop_respawn
      @spawned_boss = spawn.spawn_one(false)
    end

    def despawn_boss
      if boss = @spawned_boss
        boss.delete_me
        @spawned_boss = nil
      end
    end

    def unload
      despawn_boss
    end

    def has_bosses? : Bool
      !@boss_npc_ids.empty?
    end

    def boss_fighting? : Bool
      return false unless temp = @spawned_boss
      temp.in_combat?
    end
  end

  private EVT_SPAWN_BOSS_PRE = "spawnboss"
  private EVT_DESPAWN_BOSS_PRE = "despawnboss"
  private BOSS_MIN_SPAWN_RADIUS = 250
  private BOSS_MAX_SPAWN_RADIUS = 500
  # every 240 minutes/4 hours, altars change
  private ALTAR_STATE_CHANGE_DELAY = 240 * 60 * 1000

  private ALTARS = {
    # TalkingIsland
    Altar.new(Location.new(-92481, 244812, -3505)),
    # Elven
    Altar.new(Location.new(40241, 53974, -3262)),
    # DarkElven
    Altar.new(Location.new(1851, 21697, -3305), 25750),
    # Dwarven
    Altar.new(Location.new(130133, -180968, -3271), 25800, 25782),
    # Orc
    Altar.new(Location.new(-45329, -118327, -166), 25779),
    # Kamael
    Altar.new(Location.new(-104031, 45059, -1417)),
    # Oren
    Altar.new(Location.new(80188, 47037, -3109), 25767, 25770),
    # Gludin
    Altar.new(Location.new(-86620, 151536, -3018), 25735, 25738, 25741),
    # Gludio
    Altar.new(Location.new(-14152, 120674, -2935), 25744, 25747),
    # Dion
    Altar.new(Location.new(16715, 148320, -3210), 25753, 25754, 25757),
    # Heine
    Altar.new(Location.new(120123, 219164, -3319), 25773, 25776),
    # Giran
    Altar.new(Location.new(80712, 142538, -3487), 25760, 25763, 25766),
    # Aden
    Altar.new(Location.new(152720, 24714, -2083), 25793, 25794, 25797),
    # Rune
    Altar.new(Location.new(28010, -49175, -1278)),
    # Goddard
    Altar.new(Location.new(152274, -57706, -3383), 25787, 25790),
    # Schuttgart
    Altar.new(Location.new(82066, -139418, -2220), 25784),
    # Primeval
    Altar.new(Location.new(10998, -24068, -3603)),
    # Dragon Valley
    Altar.new(Location.new(69592, 118694, -3417))
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    ALTARS.each_with_index do |altar, i|
      if altar.has_bosses?
        start_quest_timer(make_spawn_boss_evt(i), ALTAR_STATE_CHANGE_DELAY, nil, nil)
      end
    end
  end

  private def make_spawn_boss_evt(altar_index)
    "#{EVT_SPAWN_BOSS_PRE}#{altar_index}"
  end

  private def make_despawn_boss_evt(altar_index)
    "#{EVT_DESPAWN_BOSS_PRE}#{altar_index}"
  end

  private def spawn_boss_evt?(event)
    event.starts_with?(EVT_SPAWN_BOSS_PRE)
  end

  private def despawn_boss_evt?(event)
    event.starts_with?(EVT_DESPAWN_BOSS_PRE)
  end

  private def get_spawn_boss_index(event)
    event.from(EVT_SPAWN_BOSS_PRE.size).to_i
  end

  private def get_despawn_boss_index(event)
    event.from(EVT_DESPAWN_BOSS_PRE.size).to_i
  end

  def unload(remove_from_list)
    info "Unloading altars due to script unloading."

    ALTARS.each &.unload

    super
  end

  def on_adv_event(event, npc, player)
    if spawn_boss_evt?(event)
      altar_idx = get_spawn_boss_index(event)
      altar = ALTARS[altar_idx]
      begin
        debug "Spawning boss at #{altar.@middle_point}"
        altar.spawn_boss
        start_quest_timer(make_despawn_boss_evt(altar_idx), ALTAR_STATE_CHANGE_DELAY, nil, nil)
      rescue e
        error "Failed to spawn altar boss."
        error e
        # let's try again to spawn it in 5 seconds
        start_quest_timer(event, 5000, nil, nil)
      end
    elsif despawn_boss_evt?(event)
      altar_idx = get_despawn_boss_index(event)
      altar = ALTARS[altar_idx]
      if altar.boss_fighting?
        # periodically check if the altar boss is fighting, only despawn when not fighting anymore
        start_quest_timer(event, 5000, nil, nil)
      else
        altar.despawn_boss
        start_quest_timer(make_spawn_boss_evt(altar_idx), ALTAR_STATE_CHANGE_DELAY, nil, nil)
      end
    end

    nil
  end
end
