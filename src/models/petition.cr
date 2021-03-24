require "../enums/petition_state"
require "../enums/petition_type"

class Petition
  include Packets::Outgoing

  getter submit_time, content, id, type
  getter log_messages = Concurrent::Array(CreatureSay).new
  getter! petitioner : L2PcInstance
  getter! responder : L2PcInstance
  property state : PetitionState = PetitionState::PENDING

  def initialize(petitioner : L2PcInstance, content : String, type : Int32)
    @id = IdFactory.next
    @type = PetitionType[type - 1]
    @content = content
    @petitioner = petitioner
    @submit_time = Time.ms
  end

  def add_log_message(cs : CreatureSay) : Bool
    @log_messages << cs
    true
  end

  def end_petition_consultation(end_state : PetitionState)
    self.state = end_state

    responder = responder?
    if responder && responder.online?
      if end_state.responder_reject?
        petitioner.send_message("Your petition was rejected. Please try again later.")
      else
        # Ending petition consultation with <Player>.
        sm = SystemMessage.petition_ended_with_c1
        sm.add_string(petitioner.name)
        responder.send_packet(sm)

        if end_state.petitioner_cancel?
          # Receipt No. <ID> petition cancelled.
          sm = SystemMessage.recent_no_s1_canceled
          sm.add_int(id)
          responder.send_packet(sm)
        end
      end
    end

    # End petition consultation and inform them, if they are still online. And if petitioner is online, enable Evaluation button
    petitioner = petitioner?
    if petitioner && petitioner.online?
      petitioner.send_packet(SystemMessageId::THIS_END_THE_PETITION_PLEASE_PROVIDE_FEEDBACK)
      petitioner.send_packet(PetitionVotePacket::STATIC_PACKET)
    end

    PetitionManager.completed_petitions[id] = self
    !!PetitionManager.pending_petitions.delete(id)
  end

  def type_as_string : String
    @type.to_s.sub("_", " ")
  end

  def send_petitioner_packet(response_packet : GameServerPacket)
    petitioner = petitioner?
    if petitioner.nil? || !petitioner.online?
      # Allows petitioners to see the results of their petition when
      # they log back into the game.

      # end_petition_consultation(PetitionState::PETITIONER_MISSING)
      return
    end

    petitioner.send_packet(response_packet)
  end

  def send_responder_packet(response_packet : GameServerPacket)
    responder = responder?
    if responder.nil? || !responder.online?
      end_petition_consultation(PetitionState::RESPONDER_MISSING)
      return
    end

    responder.send_packet(response_packet)
  end

  def responder=(pc : L2PcInstance)
    if responder?
      return
    end

    @responder = pc
  end
end
