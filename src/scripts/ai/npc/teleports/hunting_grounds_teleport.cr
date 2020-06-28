class Scripts::HuntingGroundsTeleport < AbstractNpcAI
  # NPCs
  private PRIESTS = {
    31078, 31079, 31080, 31081, 31082, 31083, 31084, 31085, 31086, 31087, 31088,
    31089, 31090, 31091, 31168, 31169, 31692, 31693, 31694, 31695, 31997, 31998
  }

  private DAWN_NPCS = {
    31078, 31079, 31080, 31081, 31082, 31083, 31084, 31168, 31692, 31694, 31997
  }

  def initialize
    super(HuntingGroundsTeleport.simple_name, "ai/npc/Teleports")

    add_start_npc(PRIESTS)
    add_talk_id(PRIESTS)
  end

  def on_talk(npc, pc)
    player_cabal = SevenSigns.instance.get_player_cabal(pc.l2id)

    if player_cabal == SevenSigns::CABAL_NULL
      if DAWN_NPCS.includes?(npc.id)
        return "dawn_tele-no.htm"
      else
        return "dusk_tele-no.htm"
      end
    end

    check = SevenSigns.instance.seal_validation_period? &&
    player_cabal == SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_GNOSIS) &&
    SevenSigns.instance.get_player_seal(pc.l2id) == SevenSigns::SEAL_GNOSIS

    case npc.id
    when 31078, 31085
      html = check ? "low_gludin.htm" : "hg_gludin.htm"
    when 31079, 31086
      html = check ? "low_gludio.htm" : "hg_gludio.htm"
    when 31080, 31087
      html = check ? "low_dion.htm" : "hg_dion.htm"
    when 31081, 31088
      html = check ? "low_giran.htm" : "hg_giran.htm"
    when 31082, 31089
      html = check ? "low_heine.htm" : "hg_heine.htm"
    when 31083, 31090
      html = check ? "low_oren.htm" : "hg_oren.htm"
    when 31084, 31091
      html = check ? "low_aden.htm" : "hg_aden.htm"
    when 31168, 31169
      html = check ? "low_hw.htm" : "hg_hw.htm"
    when 31692, 31693
      html = check ? "low_goddard.htm" : "hg_goddard.htm"
    when 31694, 31695
      html = check ? "low_rune.htm" : "hg_rune.htm"
    when 31997, 31998
      html = check ? "low_schuttgart.htm" : "hg_schuttgart.htm"
    end


    html || ""
  end
end
