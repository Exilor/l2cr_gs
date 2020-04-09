class Scripts::HideoutOfTheDawn < AbstractInstance
  private class HOTDWorld < InstanceWorld
  end

  # NPCs
  private WOOD = 32593
  private JAINA = 32617
  # Location
  private WOOD_LOC = Location.new(-23758, -8959, -5384)
  private JAINA_LOC = Location.new(147072, 23743, -1984)
  # Misc
  private TEMPLATE_ID = 113

  def initialize
    super(self.class.simple_name)

    add_first_talk_id(JAINA)
    add_start_npc(WOOD)
    add_talk_id(WOOD, JAINA)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "32617-01.html", "32617-02a.html"
      event
    when "32617-02.html"
      pc = pc.not_nil!
      pc.instance_id = 0
      pc.tele_to_location(JAINA_LOC, true)
      event
    when "32593-01.html"
      pc = pc.not_nil!
      enter_instance(pc, HOTDWorld.new, "HideoutOfTheDawn.xml", TEMPLATE_ID)
      event
    else
      # [automatically added else]
    end

  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world.add_allowed(pc.l2id)
    end

    teleport_player(pc, WOOD_LOC, world.instance_id, false)
  end
end
