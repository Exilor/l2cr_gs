class Scripts::CastleBlacksmith < AbstractNpcAI
  # Blacksmith IDs
  private NPCS = {
    35098, # Blacksmith (Gludio)
    35140, # Blacksmith (Dion)
    35182, # Blacksmith (Giran)
    35224, # Blacksmith (Oren)
    35272, # Blacksmith (Aden)
    35314, # Blacksmith (Innadril)
    35361, # Blacksmith (Goddard)
    35507, # Blacksmith (Rune)
    35553  # Blacksmith (Schuttgart)
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
    add_first_talk_id(NPCS)
  end

  private def has_rights?(player, npc) : Bool
    player.override_castle_conditions? ||
    npc.my_lord?(player) ||
    (player.clan_id == npc.castle.owner_id) && player.has_clan_privilege?(ClanPrivilege::CS_MANOR_ADMIN)
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!
    player = player.not_nil!
    if event.casecmp?("#{npc.id}-02.html") && has_rights?(player, npc)
      event
    end
  end

  def on_first_talk(npc, player)
    has_rights?(player, npc) ? "#{npc.id}-01.html" : "no.html"
  end
end
