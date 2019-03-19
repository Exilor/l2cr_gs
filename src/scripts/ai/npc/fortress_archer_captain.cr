class NpcAI::FortressArcherCaptain < AbstractNpcAI
  # NPCs
  private ARCHER_CAPTAIN = {
    35661, # Shanty Fortress
    35692, # Southern Fortress
    35730, # Hive Fortress
    35761, # Valley Fortress
    35799, # Ivory Fortress
    35830, # Narsell Fortress
    35861, # Bayou Fortress
    35899, # White Sands Fortress
    35930, # Borderland Fortress
    35968, # Swamp Fortress
    36006, # Archaic Fortress
    36037, # Floran Fortress
    36075, # Cloud Mountain
    36113, # Tanor Fortress
    36144, # Dragonspine Fortress
    36175, # Antharas's Fortress
    36213, # Western Fortress
    36251, # Hunter's Fortress
    36289, # Aaru Fortress
    36320, # Demon Fortress
    36358  # Monastic Fortress
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(ARCHER_CAPTAIN)
    add_first_talk_id(ARCHER_CAPTAIN)
  end

  def on_first_talk(npc, player)
    owner_clan = npc.fort.owner_clan?
    owner_id = owner_clan ? owner_clan.id : 0
    if player.clan? && player.clan_id == owner_id
      return "FortressArcherCaptain.html"
    end

    "FortressArcherCaptain-01.html"
  end
end
