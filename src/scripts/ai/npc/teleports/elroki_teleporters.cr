class Scripts::ElrokiTeleporters < AbstractNpcAI
  # NPCs
  private ORAHOCHIN = 32111
  private GARIACHIN = 32112
  # Locations
  private TELEPORT_ORAHOCIN = Location.new(5171, -1889, -3165)
  private TELEPORT_GARIACHIN = Location.new(7651, -5416, -3155)

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_first_talk_id(ORAHOCHIN, GARIACHIN)
    add_start_npc(ORAHOCHIN, GARIACHIN)
    add_talk_id(ORAHOCHIN, GARIACHIN)
  end

  def on_talk(npc, pc)
    if !pc.in_combat?
      if npc.id == ORAHOCHIN
        pc.tele_to_location(TELEPORT_ORAHOCIN)
      else
        pc.tele_to_location(TELEPORT_GARIACHIN)
      end
    else
      return "#{npc.id}-no.html"
    end

    super
  end
end
