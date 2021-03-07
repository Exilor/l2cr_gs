class Packets::Incoming::RequestDuelStart < GameClientPacket
  @player_name = ""
  @party_duel = false

  private def read_impl
    @player_name = s
    @party_duel = d == 1
  end

  private def run_impl
    return unless pc = active_char
    unless target = L2World.get_player(@player_name)
      return
    end

    if pc == target
      if @party_duel
        send_packet(SystemMessageId::THERE_IS_NO_OPPONENT_TO_RECEIVE_YOUR_CHALLENGE_FOR_A_DUEL)
      end

      return
    end

    unless pc.inside_radius?(target, 250, false, false)
      sm = SystemMessage.c1_cannot_receive_a_duel_challenge_because_c1_is_too_far_away
      sm.add_string(target.name)
      send_packet(sm)
      return
    end

    unless DuelManager.can_duel?(pc, pc, @party_duel)
      return
    end

    unless DuelManager.can_duel?(pc, target, @party_duel)
      return
    end

    if @party_duel
      if !pc.in_party? || !pc.party.not_nil!.leader?(pc) || !target.in_party? || pc.party.not_nil!.includes?(target)
        send_packet(SystemMessageId::YOU_ARE_UNABLE_TO_REQUEST_A_DUEL_AT_THIS_TIME)
        return
      end

      pc.party.not_nil!.members.each do |pl|
        unless DuelManager.can_duel?(pc, pl, @party_duel)
          return
        end
      end

      party_leader = target.party.not_nil!.leader

      target.party.not_nil!.members.each do |pl|
        unless DuelManager.can_duel?(pc, pl, @party_duel)
          return
        end
      end

      if party_leader
        if !party_leader.processing_request?
          pc.on_transaction_request(party_leader)
          party_leader.send_packet(ExDuelAskStart.new(pc.name, @party_duel))
          debug { "#{pc} requested a duel with #{party_leader.name}." }

          sm = SystemMessage.c1_party_has_been_challenged_to_a_duel
          sm.add_string(party_leader.name)
          send_packet(sm)

          sm = SystemMessage.c1_party_has_challenged_your_party_to_a_duel
          sm.add_string(pc.name)
          target.send_packet(sm)
        else
          sm = SystemMessage.c1_is_busy_try_later
          sm.add_string(party_leader.name)
          send_packet(sm)
        end
      end
    else
      if !target.processing_request?
        pc.on_transaction_request(target)
        target.send_packet(ExDuelAskStart.new(pc.name, @party_duel))
        debug { "#{pc} requested a duel with #{target.name}." }

        sm = SystemMessage.c1_has_been_challenged_to_a_duel
        sm.add_string(target.name)
        send_packet(sm)

        sm = SystemMessage.c1_has_challenged_you_to_a_duel
        sm.add_string(pc.name)
        target.send_packet(sm)
      else
        sm = SystemMessage.c1_is_busy_try_later
        sm.add_string(target.name)
        send_packet(sm)
      end
    end
  end
end
