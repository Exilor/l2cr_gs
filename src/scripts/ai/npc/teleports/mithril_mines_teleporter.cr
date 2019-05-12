class Scripts::MithrilMinesTeleporter < AbstractNpcAI
  # NPC
  private TELEPORT_CRYSTAL = 32652
  # Location
  private LOCS = {
    Location.new(171946, -173352, 3440),
    Location.new(175499, -181586, -904),
    Location.new(173462, -174011, 3480),
    Location.new(179299, -182831, -224),
    Location.new(178591, -184615, -360),
    Location.new(175499, -181586, -904)
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(TELEPORT_CRYSTAL)
    add_first_talk_id(TELEPORT_CRYSTAL)
    add_talk_id(TELEPORT_CRYSTAL)
  end

  def on_adv_event(event, npc, player)
    index = event.to_i - 1
    if loc = LOCS[index]?
      player.not_nil!.tele_to_location(loc, false)
    end

    super
  end

  def on_first_talk(npc, player)
    if npc.inside_radius?(173147, -173762, 0, L2Npc::INTERACTION_DISTANCE, false, true)
      return "32652-01.htm"
    end

    if npc.inside_radius?(181941, -174614, 0, L2Npc::INTERACTION_DISTANCE, false, true)
      return "32652-02.htm"
    end

    if npc.inside_radius?(179560, -182956, 0, L2Npc::INTERACTION_DISTANCE, false, true)
      return "32652-03.htm"
    end

    super
  end
end
