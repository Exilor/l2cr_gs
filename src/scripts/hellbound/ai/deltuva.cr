class Scripts::Deltuva < AbstractNpcAI
  # NPCs
  private DELTUVA = 32313
  # Location
  private TELEPORT = Location.new(17934, 283189, -9701)

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_start_npc(DELTUVA)
    add_talk_id(DELTUVA)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if event.casecmp?("teleport")
      q = pc.get_quest_state(Scripts::Q00132_MatrasCuriosity.simple_name)
      if q.nil? || !q.completed?
        return "32313-02.htm"
      end
      pc.tele_to_location(TELEPORT)
    end

    super
  end
end
