class Scripts::CastleAmbassador < AbstractNpcAI
  # NPCs
  private CASTLE_AMBASSADORS = {
    36393, 36394, 36437, 36435, # Gludio
    36395, 36436, 36439, 36441, # Dion
    36396, 36440, 36444, 36449, 36451, # Giran
    36397, 36438, 36442, 36443, 36446, # Oren
    36398, 36399, 36445, 36448, # Aden
    36400, 36450, # Innadril
    36401, 36447, 36453, # Goddard
    36433, 36452, 36454, # Rune
    36434, 36455 # Schuttgart
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(CASTLE_AMBASSADORS)
    add_talk_id(CASTLE_AMBASSADORS)
    add_first_talk_id(CASTLE_AMBASSADORS)
    add_event_received_id(CASTLE_AMBASSADORS)
    add_spawn_id(CASTLE_AMBASSADORS)
  end

  def on_adv_event(event, npc, player)
    if npc
      fort = npc.fort

      case event
      when "signed"
        if fort.fort_state == 0
          fort.set_fort_state(2, fort.get_castle_id_by_ambassador(npc.id))
          cancel_quest_timer("DESPAWN", npc, nil)
          start_quest_timer("DESPAWN", 3000, npc, nil)
          html = "ambassador-05.html"
        elsif fort.fort_state == 1
          html = "ambassador-04.html"
        end
      when "rejected"
        if fort.fort_state == 0
          fort.set_fort_state(1, fort.get_castle_id_by_ambassador(npc.id))
          cancel_quest_timer("DESPAWN", npc, nil)
          start_quest_timer("DESPAWN", 3000, npc, nil)
          html = "ambassador-02.html"
        elsif fort.fort_state == 2
          html = "ambassador-02.html"
        end
      when "DESPAWN"
        if fort.fort_state == 0
          fort.set_fort_state(1, fort.get_castle_id_by_ambassador(npc.id))
        end
        cancel_quest_timer("DESPAWN", npc, nil)
        npc.broadcast_event("DESPAWN", 1000, nil)
        npc.delete_me
      end

      if html && player
        packet = NpcHtmlMessage.new(npc.l2id)
        packet.html = get_htm(player, html)
        packet["%castleName%"] = fort.get_castle_by_ambassador(npc.id).name
        player.send_packet(packet)
      end
    end

    super
  end

  def on_event_received(event_name, sender, receiver, reference)
    if receiver
      receiver.delete_me
    end

    super
  end

  def on_first_talk(npc, player)
    fort = npc.fort
    owner_clan = fort.owner_clan?
    fort_owner = owner_clan ? owner_clan.id : 0
    html = nil

    if player.clan_leader? && player.clan_id == fort_owner
      html = fort.border_fortress? ? "ambassador-01.html" : "ambassador.html"
    else
      html = "ambassador-03.html"
    end

    packet = NpcHtmlMessage.new(npc.l2id)
    packet.html = get_htm(player, html)
    packet["%castleName%"] = fort.get_castle_by_ambassador(npc.id).name
    player.send_packet(packet)

    nil
  end

  def on_spawn(npc)
    castle = npc.fort.get_castle_by_ambassador(npc.id)
    if castle.owner_id == 0
      npc.delete_me
    else
      start_quest_timer("DESPAWN", 3_600_000, npc, nil)
    end

    super
  end
end
