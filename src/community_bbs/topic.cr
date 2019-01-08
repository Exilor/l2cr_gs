require "./manager/topic_bbs_manager"

class Topic
  include Loggable

  NORMAL = 0
  MEMO = 1

  getter id, forum_id, owner_name, date

  enum ConstructorType : UInt8
    RESTORE, CREATE
  end

  def initialize(ct : ConstructorType, @id : Int32, @forum_id : Int32, @topic_name : String, @date : Int64, @owner_name : String, @owner_id : Int32, @type : Int32, @creply : Int32)
    TopicBBSManager.add_topic(self)

    if ct.create?
      insert_in_db
    end
  end

  def insert_in_db
    sql = "INSERT INTO topic (topic_id,topic_forum_id,topic_name,topic_date,topic_ownername,topic_ownerid,topic_type,topic_reply) values (?,?,?,?,?,?,?,?)"
    GameDB.exec(
      sql,
      @id,
      @forum_id,
      @topic_name,
      @date,
      @owner_name,
      @owner_id,
      @type,
      @creply
    )
  rescue e
    error e
  end

  def name
    @topic_name
  end
end
