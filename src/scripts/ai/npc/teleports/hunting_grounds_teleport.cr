class NpcAI::HuntingGroundsTeleport < AbstractNpcAI
  # NPCs
  # @formatter:off
  private PRIESTS = {
    31078, 31079, 31080, 31081, 31082, 31083, 31084, 31085, 31086, 31087, 31088,
    31089, 31090, 31091, 31168, 31169, 31692, 31693, 31694, 31695, 31997, 31998
  }

  private DAWN_NPCS = {
    31078, 31079, 31080, 31081, 31082, 31083, 31084, 31168, 31692, 31694, 31997
  }
  # @formatter:on

  def initialize
    super(HuntingGroundsTeleport.simple_name, "ai/npc/Teleports")

    add_start_npc(PRIESTS)
    add_talk_id(PRIESTS)
  end

  def on_talk(npc, player)
    player_cabal = SevenSigns.get_player_cabal(player.l2id)

    if player_cabal == SevenSigns::CABAL_NULL
      if DAWN_NPCS.includes?(npc.id)
        return "dawn_tele-no.htm"
      else
        return "dusk_tele-no.htm"
      end
    end

    htmltext = ""

    check = SevenSigns.seal_validation_period? &&
    player_cabal == SevenSigns.get_seal_owner(SevenSigns::SEAL_GNOSIS) &&
    SevenSigns.get_player_seal(player.l2id) == SevenSigns::SEAL_GNOSIS

    case npc.id
    when 31078, 31085
      htmltext = check ? "low_gludin.htm" : "hg_gludin.htm"
    when 31079, 31086
      htmltext = check ? "low_gludio.htm" : "hg_gludio.htm"
    when 31080, 31087
      htmltext = check ? "low_dion.htm" : "hg_dion.htm"
    when 31081, 31088
      htmltext = check ? "low_giran.htm" : "hg_giran.htm"
    when 31082, 31089
      htmltext = check ? "low_heine.htm" : "hg_heine.htm"
    when 31083, 31090
      htmltext = check ? "low_oren.htm" : "hg_oren.htm"
    when 31084, 31091
      htmltext = check ? "low_aden.htm" : "hg_aden.htm"
    when 31168, 31169
      htmltext = check ? "low_hw.htm" : "hg_hw.htm"
    when 31692, 31693
      htmltext = check ? "low_goddard.htm" : "hg_goddard.htm"
    when 31694, 31695
      htmltext = check ? "low_rune.htm" : "hg_rune.htm"
    when 31997, 31998
      htmltext = check ? "low_schuttgart.htm" : "hg_schuttgart.htm"
    end

    htmltext
  end
end
