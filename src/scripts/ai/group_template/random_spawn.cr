class NpcAI::RandomSpawn < AbstractNpcAI
  private SPAWN_POINTS = {
    22341 => [ # Keltas
      Location.new(-27136, 250938, -3523),
      Location.new(-29658, 252897, -3523),
      Location.new(-27237, 251943, -3527),
      Location.new(-28868, 250113, -3479)
    ],
    22361 => [ # Keymaster
      Location.new(14091, 250533, -1940),
      Location.new(15762, 252440, -2015),
      Location.new(19836, 256212, -2090),
      Location.new(21940, 254107, -2010),
      Location.new(17299, 252943, -2015),
    ],
    25539 => [ # Typhoon
      Location.new(-20641, 255370, -3235),
      Location.new(-16157, 250993, -3058),
      Location.new(-18269, 250721, -3151),
      Location.new(-16532, 254864, -3223),
      Location.new(-19055, 253489, -3440),
      Location.new(-9684,  254256, -3148),
      Location.new(-6209,  251924, -3189),
      Location.new(-10547, 251359, -2929),
      Location.new(-7254,  254997, -3261),
      Location.new(-4883,  253171, -3322)
    ],
    25604 => [ # Mutated Elpy
      Location.new(-46080, 246368, -14183),
      Location.new(-44816, 246368, -14183),
      Location.new(-44224, 247440, -14184),
      Location.new(-44896, 248464, -14183),
      Location.new(-46064, 248544, -14183),
      Location.new(-46720, 247424, -14183)
    ]
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_spawn_id(SPAWN_POINTS.keys)
  end

  def on_spawn(npc)
    loc = SPAWN_POINTS[npc.id].sample(Rnd)
    unless npc.inside_radius?(loc, 200, false, false)
      npc.spawn.location = loc
      task = -> { npc.tele_to_location(loc, false) }
      ThreadPoolManager.schedule_general(task, 100)
    end

    super
  end
end
