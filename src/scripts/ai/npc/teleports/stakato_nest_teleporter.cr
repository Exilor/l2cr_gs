class Scripts::StakatoNestTeleporter < AbstractNpcAI
  private LOCS = {
    Location.new(80456, -52322, -5640),
    Location.new(88718, -46214, -4640),
    Location.new(87464, -54221, -5120),
    Location.new(80848, -49426, -5128),
    Location.new(87682, -43291, -4128)
  }
  # NPC
  private KINTAIJIN = 32640

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(KINTAIJIN)
    add_talk_id(KINTAIJIN)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    index = event.to_i - 1

    if LOCS.size > index
      loc = LOCS[index]
      if party = pc.party?
        party.members.each do |m|
          if m.inside_radius?(pc, 1000, true, true)
            m.tele_to_location(loc, true)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    if pc.quest_completed?(Q00240_ImTheOnlyOneYouCanTrust.simple_name)
      return "32640.htm"
    end

    "32640-no.htm"
  end
end
