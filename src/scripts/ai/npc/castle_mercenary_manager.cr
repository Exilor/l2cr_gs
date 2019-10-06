class Scripts::CastleMercenaryManager < AbstractNpcAI
  # NPCs
  private NPCS = {
    35102, # Greenspan
    35144, # Sanford
    35186, # Arvid
    35228, # Morrison
    35276, # Eldon
    35318, # Solinus
    35365, # Rowell
    35511, # Gompus
    35557  # Kendrew
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
    add_first_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    st = event.split

    case st.shift
    when "limit"
      castle = npc.castle
      msg = NpcHtmlMessage.new(npc.l2id)
      if castle.name == "aden"
        msg.html = get_htm(pc, "mercmanager-aden-limit.html")
      elsif castle.name == "rune"
        msg.html = get_htm(pc, "mercmanager-rune-limit.html")
      else
        msg.html = get_htm(pc, "mercmanager-limit.html")
      end
      msg["%feud_name%"] = 1001000 + castle.residence_id
      pc.send_packet(msg)
    when "buy"
      if SevenSigns.seal_validation_period?
        list_id = "#{npc.id}#{st.shift}".to_i
        unless npc.is_a?(L2MerchantInstance)
          raise "Expected #{npc} to be a L2MerchantInstance"
        end
        npc.show_buy_window(pc, list_id, false) # NOTE: Not affected by Castle Taxes, baseTax is 20% (done in merchant buylists)
      else
        html = "mercmanager-ssq.html"
      end
    when "main"
      html = on_first_talk(npc, pc)
    when "mercmanager-01.html"
      html = event
    end

    html
  end

  def on_first_talk(npc, pc)
    if pc.override_castle_conditions? || (pc.clan_id == npc.castle.owner_id && pc.has_clan_privilege?(ClanPrivilege::CS_MERCENARIES))
      if npc.castle.siege.in_progress?
        html = "mercmanager-siege.html"
      else
        case SevenSigns.get_seal_owner(SevenSigns::SEAL_STRIFE)
        when SevenSigns::CABAL_DUSK
          html = "mercmanager-dusk.html"
        when SevenSigns::CABAL_DAWN
          html = "mercmanager-dawn.html"
        else
          html = "mercmanager.html"
        end
      end
    else
      html = "mercmanager-no.html"
    end

    html
  end
end
