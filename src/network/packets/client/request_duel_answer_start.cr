class Packets::Incoming::RequestDuelAnswerStart < GameClientPacket
  @party_duel = 0
  @unknown = 0
  @response = 0

  def read_impl
    @party_duel = d
    unknown = d
    @response = d
  end

  def run_impl
    return unless pc = active_char

    unless requestor = pc.active_requester
      return
    end

    if @response == 1
      if requestor.in_duel?
        sm1 = SystemMessage.c1_cannot_duel_because_c1_is_already_engaged_in_a_duel
        sm1.add_string(requestor.name)
        pc.send_packet(sm1)
        return
      elsif pc.in_duel?
        send_packet(SystemMessageId::YOU_ARE_UNABLE_TO_REQUEST_A_DUEL_AT_THIS_TIME)
        return
      end

      if @party_duel == 1
        sm1 = SystemMessage.you_have_accepted_c1_challenge_to_a_party_duel_the_duel_will_begin_in_a_few_moments
        sm1.add_string(requestor.name)

        sm2 = SystemMessage.s1_has_accepted_your_challenge_to_duel_against_their_party_the_duel_will_begin_in_a_few_moments
        sm2.add_string(pc.name)
      else
        sm1 = SystemMessage.you_have_accepted_c1_challenge_to_a_duel_the_duel_will_begin_in_a_few_moments
        sm1.add_string(requestor.name)

        sm2 = SystemMessage.c1_has_accepted_your_challenge_to_a_duel_the_duel_will_begin_in_a_few_moments
        sm2.add_string(pc.name)
      end

      send_packet(sm1)
      requestor.send_packet(sm2)

      DuelManager.add_duel(requestor, pc, @party_duel == 1)
    elsif @response == -1
      sm = SystemMessage.c1_is_set_to_refuse_duel_request
      sm.add_pc_name(pc)
      requestor.send_packet(sm)
    else
      if @party_duel == 1
        sm = SystemMessage.the_opposing_party_has_declined_your_challenge_to_a_duel
      else
        sm = SystemMessage.c1_has_declined_your_challenge_to_a_duel
        sm.add_pc_name(pc)
      end
      requestor.send_packet(sm)

      pc.active_requester = nil
      requestor.on_transaction_response
    end

    pc.active_requester = nil
    requestor.on_transaction_response
  end
end
