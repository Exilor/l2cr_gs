class Packets::Outgoing::ExShowSentPostList < GameServerPacket
  def initialize(pc_id : Int32)
    @outbox = MailManager.get_outbox(pc_id)
  end

  private def write_impl
    c 0xfe
    h 0xac

    d Time.ms // 1000

    if @outbox && !@outbox.empty?
      d @outbox.size
      @outbox.each do |msg|
        d msg.id
        s msg.subject
        s msg.receiver_name
        d msg.locked? ? 1 : 0
        d msg.expiration_seconds
        d msg.unread? ? 1 : 0
        d 1
        d msg.has_attachments? ? 1 : 0
      end
    else
      d 0
    end
  end
end
