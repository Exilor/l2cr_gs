class Packets::Outgoing::ExShowReceivedPostList < GameServerPacket
  @inbox : Array(Message)?

  def initialize(pc_id : Int32)
    @inbox = MailManager.get_inbox(pc_id)
  end

  def write_impl
    c 0xfe
    h 0xaa

    d Time.ms / 1000

    inbox = @inbox

    if inbox && !inbox.empty?
      d inbox.size
      inbox.each do |msg|
        d msg.id
        s msg.subject
        s msg.sender_name
        d msg.locked? ? 1 : 0
        d msg.expiration_seconds
        d msg.unread? ? 1 : 0
        d 1
        d msg.has_attachments? ? 1 : 0
        d msg.returned? ? 1 : 0
        d msg.send_by_system
        d 0
      end
    else
      d 0
    end
  end
end
