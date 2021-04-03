class L2Request
  include Synchronizable

  private REQUEST_TIMEOUT = 15

  property partner : L2PcInstance?
  property request_packet : GameClientPacket?

  def initialize(pc : L2PcInstance)
    @pc = pc
    clear
  end

  def clear
    @partner = @request_packet = nil
    @requestor = @answerer = false
  end

  def set_request(partner : L2PcInstance?, packet : GameClientPacket?) : Bool
    sync do
      if partner.nil?
        @pc.send_packet(SystemMessageId::YOU_HAVE_INVITED_THE_WRONG_TARGET)
        return false
      end

      if partner.request.processing_request?
        sm = Packets::Outgoing::SystemMessage.c1_is_busy_try_later
        sm.add_string(partner.name)
        @pc.send_packet(sm)
        return false
      end

      if processing_request?
        @pc.send_packet(SystemMessageId::WAITING_FOR_ANOTHER_REPLY)
        return false
      end

      @partner = partner
      @request_packet = packet
      self.on_request_timer = true
      partner.request.partner = @pc
      partner.request.request_packet = packet
      partner.request.on_request_timer = false
      true
    end
  end

  protected def on_request_timer=(is_requestor : Bool)
    @answerer = !(@requestor = is_requestor)
    ThreadPoolManager.schedule_general(->clear, REQUEST_TIMEOUT &* 1000)
  end

  def on_request_response
    @partner.try &.request.try &.clear
    clear
  end

  def processing_request? : Bool
    !!@partner
  end
end
