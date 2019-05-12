class Scripts::GatekeeperSpirit < AbstractNpcAI
  # NPCs
  private GATEKEEPER_SPIRIT_ENTER = 31111
  private GATEKEEPER_SPIRIT_EXIT = 31112
  private LILITH = 25283
  private ANAKIM = 25286
  # Exit gatekeeper spawn locations
  private SPAWN_LILITH_GATEKEEPER = Location.new(184410, -10111, -5488)
  private SPAWN_ANAKIM_GATEKEEPER = Location.new(184410, -13102, -5488)
  # Teleport
  private TELEPORT_DUSK = Location.new(184464, -13104, -5504)
  private TELEPORT_DAWN = Location.new(184448, -10112, -5504)
  private EXIT = Location.new(182960, -11904, -4897)

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(GATEKEEPER_SPIRIT_ENTER, GATEKEEPER_SPIRIT_EXIT)
    add_first_talk_id(GATEKEEPER_SPIRIT_ENTER, GATEKEEPER_SPIRIT_EXIT)
    add_talk_id(GATEKEEPER_SPIRIT_ENTER, GATEKEEPER_SPIRIT_EXIT)
    add_kill_id(LILITH, ANAKIM)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "ANAKIM"
      add_spawn(GATEKEEPER_SPIRIT_EXIT, SPAWN_ANAKIM_GATEKEEPER, false, 900000)
    when "LILITH"
      add_spawn(GATEKEEPER_SPIRIT_EXIT, SPAWN_LILITH_GATEKEEPER, false, 900000)
    when "TeleportIn"
      pc = pc.not_nil!
      cabal = SevenSigns.get_player_cabal(pc.l2id)
      avarice_owner = SevenSigns.get_seal_owner(SevenSigns::SEAL_AVARICE)
      winner = SevenSigns.cabal_highest_score
      if !SevenSigns.seal_validation_period?
        html = "31111-no.html"
      elsif winner == SevenSigns::CABAL_DUSK && cabal == SevenSigns::CABAL_DUSK && avarice_owner == SevenSigns::CABAL_DUSK
        pc.tele_to_location(TELEPORT_DUSK, false)
      elsif winner == SevenSigns::CABAL_DAWN && cabal == SevenSigns::CABAL_DAWN && avarice_owner == SevenSigns::CABAL_DAWN
        pc.tele_to_location(TELEPORT_DAWN, false)
      else
        html = "31111-no.html"
      end
    when "TeleportOut"
      pc.not_nil!.tele_to_location(EXIT, true)
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when ANAKIM
      start_quest_timer("ANAKIM", 10000, npc, killer)
    when LILITH
      start_quest_timer("LILITH", 10000, npc, killer)
    end

    super
  end
end
