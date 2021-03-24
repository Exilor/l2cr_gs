class Scripts::TownPets < AbstractNpcAI
  private PETS = {
    31202, # Maximus
    31203, # Moon Dancer
    31204, # Georgio
    31205, # Katz
    31206, # Ten Ten
    31207, # Sardinia
    31208, # La Grange
    31209, # Misty Rain
    31266, # Kaiser
    31593, # Dorothy
    31758, # Rafi
    31955  # Ruby
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    if Config.allow_pet_walkers
      add_spawn_id(PETS)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless npc
    if event.casecmp?("move")
      loc_x = npc.spawn.x + Rnd.rand(-100..100)
      loc_y = npc.spawn.y + Rnd.rand(-100..100)
      # npc.set_running # custom (looks better if they don't run)
      npc.set_intention(AI::MOVE_TO, Location.new(loc_x, loc_y, npc.z, 0))
      start_quest_timer("move", 10_000, npc, nil)
    end

    nil
  end

  def on_spawn(npc)
    start_quest_timer("move", 3000, npc, nil)
    super
  end
end
