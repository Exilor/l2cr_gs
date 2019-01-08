require "../models/entity/message"
require "./tasks/message_deletion_task"

module MailManager
  extend self
  extend Loggable

  private MESSAGES = Hash(Int32, Message).new

  def load
    timer = Timer.new
    count = 0

    GameDB.each("SELECT * FROM messages ORDER BY expiration") do |rs|
      msg = Message.new(rs)
      msg_id = msg.id
      MESSAGES[msg_id] = msg
      count += 1
      expiration = msg.expiration
      task = MessageDeletionTask.new(msg_id)
      if expiration < Time.ms
        ThreadPoolManager.schedule_general(task, 10000)
      else
        ThreadPoolManager.schedule_general(task, expiration - Time.ms)
      end
    end

    info "Loaded #{count} messages in #{timer} s."
  rescue e
    error e
  end

  def get_message(msg_id : Int) : Message?
    MESSAGES[msg_id]?
  end

  def messages
    MESSAGES.local_each_value
  end

  def has_unread_post?(pc : L2PcInstance) : Bool
    messages.any? { |msg| msg.receiver_id == pc.l2id && msg.unread? }
  end

  def get_inbox_size(obj_id : Int) : Int32
    messages.count do |msg|
      msg.receiver_id == obj_id && !msg.deleted_by_receiver?
    end
  end

  def get_outbox_size(obj_id : Int) : Int32
    messages.count do |msg|
      msg.sender_id == obj_id && !msg.deleted_by_sender?
    end
  end

  def get_inbox(obj_id : Int) : Array(Message)
    messages.select do |msg|
      msg.receiver_id == obj_id && !msg.deleted_by_receiver?
    end.to_a
  end

  def get_outbox(obj_id : Int) : Array(Message)
    messages.select do |msg|
      msg.sender_id == obj_id && !msg.deleted_by_sender?
    end.to_a
  end

  def send_message(msg)
    MESSAGES[msg.id] = msg

    begin
      sql = "INSERT INTO messages (messageId, senderId, receiverId, subject, content, expiration, reqAdena, hasAttachments, isUnread, isDeletedBySender, isDeletedByReceiver, sendBySystem, isReturned) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
      GameDB.exec(
        sql,
        msg.@message_id,
        msg.@sender_id,
        msg.@receiver_id,
        msg.@subject,
        msg.@content,
        msg.@expiration,
        msg.@req_adena,
        msg.@has_attachments.to_s,
        msg.@unread.to_s,
        msg.@deleted_by_sender.to_s,
        msg.@deleted_by_receiver.to_s,
        msg.@send_by_system.to_s,
        msg.@returned.to_s
      )
    rescue e
      error "Error saving message #{msg}."
      error e
    end

    if receiver = L2World.get_player(msg.receiver_id)
      receiver.send_packet(Packets::Outgoing::ExNoticePostArrived::TRUE)
    end

    task = MessageDeletionTask.new(msg.id)
    ThreadPoolManager.schedule_general(task, msg.expiration - Time.ms)
  end

  def mark_as_read_in_db(msg_id : Int32)
    GameDB.exec("UPDATE messages SET isUnread = 'false' WHERE messageId = ?", msg_id)
  rescue e
    error e
  end

  def mark_as_deleted_by_sender_in_db(msg_id : Int32)
    GameDB.exec("UPDATE messages SET isDeletedBySender = 'true' WHERE messageId = ?", msg_id)
  rescue e
    error e
  end

  def mark_as_deleted_by_receiver_in_db(msg_id : Int32)
    GameDB.exec("UPDATE messages SET isDeletedByReceiver = 'true' WHERE messageId = ?", msg_id)
  rescue e
    error e
  end

  def remove_attachments_in_db(msg_id : Int32)
    GameDB.exec("UPDATE messages SET hasAttachments = 'false' WHERE messageId = ?", msg_id)
  rescue e
    error e
  end

  def delete_message_in_db(msg_id : Int32)
    GameDB.exec("DELETE FROM messages WHERE messageId = ?", msg_id)
  end
end
