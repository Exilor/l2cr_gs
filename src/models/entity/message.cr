require "../item_containers/mail"

class Message
  include Synchronizable

  EXPIRATION = 360 # 15 days
  COD_EXPIRATION = 12 # 12 hours

  UNLOAD_ATTACHMENTS_INTERVAL = 900000 # 15-30 mins

  # post state
  DELETED = 0
  READ = 1
  REJECTED = 2

  enum SendBySystem : UInt8
    PLAYER, NEWS, NONE, ALEGRIA
  end

  @attachments : Mail?

  getter sender_id : Int32
  getter receiver_id : Int32
  getter subject : String
  getter content : String
  getter expiration : Int64
  getter send_by_system = 0
  getter req_adena : Int64

  getter? unread : Bool
  getter? deleted_by_sender : Bool
  getter? deleted_by_receiver : Bool
  getter? has_attachments : Bool

  property? returned : Bool = false

  def initialize(rs : ResultSetReader)
    @message_id = rs.get_i32("messageId")
    @sender_id = rs.get_i32("senderId")
    @receiver_id = rs.get_i32("receiverId")
    @subject = rs.get_string("subject")
    @content = rs.get_string("content")
    @expiration = rs.get_i64("expiration")
    @req_adena = rs.get_i64("reqAdena")
    @has_attachments = rs.get_bool("hasAttachments")
    @unread = rs.get_bool("isUnread")
    @deleted_by_sender = rs.get_bool("isDeletedBySender")
    @deleted_by_receiver = rs.get_bool("isDeletedByReceiver")
    @send_by_system = rs.get_i32("sendBySystem")
    @returned = rs.get_bool("isReturned")
  end

  def initialize(@sender_id : Int32, @receiver_id : Int32, cod : Bool, @subject : String, @content : String, @req_adena : Int64)
    @message_id = IdFactory.next
    @expiration = cod ? Time.ms + (COD_EXPIRATION * 3600000) : Time.ms + (EXPIRATION * 3600000)
    @has_attachments = false
    @unread = true
    @deleted_by_sender = false
    @deleted_by_receiver = false
  end

  def initialize(@receiver_id : Int32, @subject : String, @content : String, send_by_system : SendBySystem)
    @message_id = IdFactory.next
    @sender_id = -1
    @expiration = Time.ms + (EXPIRATION * 3600000)
    @req_adena = 0i64
    @has_attachments = false
    @unread = true
    @deleted_by_sender = true
    @deleted_by_receiver = false
    @send_by_system = send_by_system.to_i
    @returned = false
  end

  def initialize(msg : Message)
    @message_id = IdFactory.next
    @sender_id = msg.sender_id
    @receiver_id = msg.sender_id
    @subject = ""
    @content = ""
    @expiration = Time.ms + (EXPIRATION * 3600000)
    @unread = true
    @deleted_by_sender = true
    @deleted_by_receiver = false
    @send_by_system = SendBySystem::NONE.to_i
    @returned = true
    @req_adena = 0i64
    @has_attachments = true
    @attachments = msg.attachments
    msg.remove_attachments
    @attachments.not_nil!.message_id = @message_id
    task = AttachmentsUnloadTask.new(self)
    @unload_task = ThreadPoolManager.schedule_general(task, UNLOAD_ATTACHMENTS_INTERVAL + Rnd.rand(UNLOAD_ATTACHMENTS_INTERVAL))
  end

  def id : Int32
    @message_id
  end

  def sender_name : String
    if temp = @sender_name
      return temp
    end

    if @send_by_system != 0
      return "****"
    end

    @sender_name = CharNameTable.get_name_by_id(@sender_id) || ""
  end

  def receiver_name : String
    if temp = @receiver_name
      return temp
    end
    @receiver_name = CharNameTable.get_name_by_id(@receiver_id) || ""
  end

  def locked? : Bool
    @req_adena > 0
  end

  def expiration_seconds : Int32
    (@expiration / 1000).to_i32
  end

  def mark_as_read
    if @unread
      @unread = false
      MailManager.mark_as_read_in_db(@message_id)
    end
  end

  def set_deleted_by_sender
    unless @deleted_by_sender
      @deleted_by_sender = true
      if @deleted_by_receiver
        MailManager.delete_message_in_db(@message_id)
      else
        MailManager.mark_as_deleted_by_sender_in_db(@message_id)
      end
    end
  end

  def set_deleted_by_receiver
    unless @deleted_by_receiver
      @deleted_by_receiver = true
      if @deleted_by_sender
        MailManager.delete_message_in_db(@message_id)
      else
        MailManager.mark_as_deleted_by_receiver_in_db(@message_id)
      end
    end
  end

  def attachments : Mail?
    sync do
      return unless @has_attachments
      unless @attachments
        @attachments = Mail.new(@sender_id, @message_id)
        @attachments.not_nil!.restore
        task = AttachmentsUnloadTask.new(self)
        @unload_task = ThreadPoolManager.schedule_general(
          task,
          UNLOAD_ATTACHMENTS_INTERVAL + Rnd.rand(UNLOAD_ATTACHMENTS_INTERVAL)
        )
      end
      @attachments
    end
  end

  def attachments!
    attachments.not_nil!
  end

  def remove_attachments
    sync do
      if @attachments
        @attachments = nil
        @has_attachments = false
        MailManager.remove_attachments_in_db(@message_id)
        @unload_task.try &.cancel
      end
    end
  end

  def create_attachments : Mail?
    sync do
      return if @has_attachments || @attachments
      @attachments = Mail.new(@sender_id, @message_id)
      @has_attachments = true
      task = AttachmentsUnloadTask.new(self)
      @unload_task = ThreadPoolManager.schedule_general(
        task,
        UNLOAD_ATTACHMENTS_INTERVAL + Rnd.rand(UNLOAD_ATTACHMENTS_INTERVAL)
      )
      @attachments
    end
  end

  def unload_attachments
    if att = @attachments
      att.delete_me
      @attachments = nil
    end
  end

  class AttachmentsUnloadTask
    include Runnable

    initializer msg: Message

    def run
      if msg = @msg
        msg.unload_attachments
        @msg = nil
      end
    end
  end
end
