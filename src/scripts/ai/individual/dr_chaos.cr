class Scripts::DrChaos < AbstractNpcAI
  private DR_CHAOS = 32033
  private STRANGE_MACHINE = 32032
  private CHAOS_GOLEM = 25703
  private PLAYER_TELEPORT = Location.new(94832, -112624, -3304)
  private NPC_LOCATION = Location.new(-113091, -243942, -15536)

  def initialize
    super(self.class.simple_name, "ai/individual")

    @golem_spawned = false
    add_first_talk_id(DR_CHAOS)
    add_spawn_id(CHAOS_GOLEM)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    case event
    when "1"
      machine = nil
      SpawnTable.get_spawns(STRANGE_MACHINE).each do |sp|
        if machine = sp.last_spawn
          break
        end
      end
      if machine
        npc.set_intention(AI::ATTACK, machine)
        machine.broadcast_packet(SpecialCamera.new(machine, 1, -200, 15, 10000, 1000, 20000, 0, 0, 0, 0, 0))
      else
        start_quest_timer("2", 2000, npc, pc)
      end
      start_quest_timer("3", 10000, npc, pc)
    when "2"
      npc.broadcast_social_action(3)
    when "3"
      npc.broadcast_packet(SpecialCamera.new(npc, 1, -150, 10, 3000, 1000, 20000, 0, 0, 0, 0, 0))
      start_quest_timer("4", 2500, npc, pc)
    when "4"
      npc.set_intention(AI::MOVE_TO, Location.new(96055, -110759, -3312, 0))
      start_quest_timer("5", 2000, npc, pc)
    when "5"
      pc.tele_to_location(PLAYER_TELEPORT)
      npc.tele_to_location(NPC_LOCATION)
      unless @golem_spawned
        golem = add_spawn(CHAOS_GOLEM, 94640, -112496, -3336, 0, false, 0)
        @golem_spawned = true
        start_quest_timer("6", 1000, golem, pc)
      end
    when "6"
      npc.broadcast_packet(SpecialCamera.new(npc, 30, -200, 20, 6000, 700, 8000, 0, 0, 0, 0, 0))
    end


    super
  end

  def on_first_talk(npc, pc)
    npc.set_intention(AI::MOVE_TO, Location.new(96323, -110914, -3328, 0))
    start_quest_timer("1", 3000, npc, pc)

    ""
  end

  def on_spawn(npc)
    npc.random_animation_enabled = false
  end
end
