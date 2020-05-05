class Scripts::Chimeras < AbstractNpcAI
  # NPCs
  private NPCS = {
    22349, # Chimera of Earth
    22350, # Chimera of Darkness
    22351, # Chimera of Wind
    22352  # Chimera of Fire
  }
  private CELTUS = 22353
  # Locations
  private LOCATIONS = {
    Location.new(3678, 233418, -3319),
    Location.new(2038, 237125, -3363),
    Location.new(7222, 240617, -2033),
    Location.new(9969, 235570, -1993)
  }
  # Skills
  private BOTTLE = 2359 # Magic Bottle
  # Items
  private DIM_LIFE_FORCE = 9680
  private LIFE_FORCE = 9681
  private CONTAINED_LIFE_FORCE = 9682

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_skill_see_id(NPCS)
    add_spawn_id(CELTUS)
    add_skill_see_id(CELTUS)
  end

  def on_spawn(npc)
    if HellboundEngine.instance.level == 7
      loc = LOCATIONS.sample(random: Rnd)
      unless npc.inside_radius?(loc, 200, false, false)
        npc.spawn.location = loc
        ThreadPoolManager.schedule_general(Teleport.new(npc, loc), 100)
      end
    end

    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if skill.id == BOTTLE && npc.alive?
      if !targets.empty? && targets[0] == npc
        if npc.hp_percent < 10
          if HellboundEngine.instance.level == 7
            HellboundEngine.instance.update_trust(3, true)
          end

          npc.dead = true
          if npc.id == CELTUS
            npc.drop_item(caster, CONTAINED_LIFE_FORCE, 1)
          else
            if Rnd.rand(100) < 80
              npc.drop_item(caster, DIM_LIFE_FORCE, 1)
            elsif Rnd.rand(100) < 80
              npc.drop_item(caster, LIFE_FORCE, 1)
            end
          end
          npc.on_decay
        end
      end
    end

    super
  end

  private struct Teleport
    initializer npc : L2Npc, loc : Location

    def call
      @npc.tele_to_location(@loc, false)
    end
  end
end
