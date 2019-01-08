require "./topic"

class Forum
  include Loggable

  ROOT = 0
  NORMAL = 1
  CLAN = 2
  MEMO = 3
  MAIL = 4

  INVISIBLE = 0
  ALL = 1
  CLANMEMBERONLY = 2
  OWNERONLY = 3

  @children = [] of Forum
  @topic = {} of Int32 => Topic
  @loaded = false
  @forum_post = 0
  @forum_name = ""
  @forum_type = 0
  @forum_perm = 0
  @owner_id = 0

  def initialize(@forum_id : Int32, @parent : Forum)
  end

  def initialize(@forum_name : String, @parent : Forum, @forum_type : Int32, @forum_perm : Int32, @owner_id : Int32)
    @forum_id = ForumsBBSManager.get_new_id
    parent.@children << self
    ForumsBBSManager.add_forum(self)
    @loaded = true
  end

  private def load
    begin
      sql = "SELECT * FROM forums WHERE forum_id=?"
      GameDB.each(sql, @forum_id) do |rs|
        @forum_name = rs.get_string("forum_name")
        @forum_post = rs.get_i32("forum_post")
        @forum_type = rs.get_i32("forum_type")
        @forum_perm = rs.get_i32("forum_perm")
        @owner_id = rs.get_i32("forum_owner_id")
      end
    rescue e
      error e
    end

    begin
      sql = "SELECT * FROM topic WHERE topic_forum_id=? ORDER BY topic_id DESC"
      GameDB.each(sql, @forum_id) do |rs|
        topic_id = rs.get_i32("topic_id")
        topic_forum_id = rs.get_i32("topic_forum_id")
        topic_name = rs.get_string("topic_name")
        topic_date = rs.get_i64("topic_date")
        topic_owner_name = rs.get_string("topic_ownername")
        topic_owner_id = rs.get_i32("topic_ownerid")
        topic_type = rs.get_i32("topic_type")
        topic_reply = rs.get_i32("topic_reply")
        t = Topic.new(
          Topic::ConstructorType::RESTORE,
          topic_id,
          topic_forum_id,
          topic_name,
          topic_date,
          topic_owner_name,
          topic_owner_id,
          topic_type,
          topic_reply
        )
        @topic[t.id] = t
      end
    rescue e
      error e
    end
  end

  private def children
    sql = "SELECT forum_id FROM forums WHERE forum_parent=?"
    GameDB.each(sql, @forum_id) do |rs|
      f = Forum.new(rs.get_i32("forum_id"), self)
      @children << f
      ForumsBBSManager.add_forum(f)
    end
  rescue e
    error e
  end

  def topic_size : Int32
    vload
    @topic.size
  end

  def get_topic(j : Int32) : Topic?
    vload
    @topic[j]?
  end

  def add_topic(t : Topic)
    vload
    @topic[t.id] = t
  end

  def id : Int32
    @forum_id
  end

  def name : String
    vload
    @forum_name
  end

  def type : Int32
    vload
    @forum_type
  end

  def get_child_by_name(name : String) : Forum?
    vload
    @children.find { |f| f.name == name }
  end

  def rm_topic_by_id(id : Int32)
    @topic.delete_first(id)
  end

  def insert_into_db
    sql = "INSERT INTO forums (forum_id,forum_name,forum_parent,forum_post,forum_type,forum_perm,forum_owner_id) VALUES (?,?,?,?,?,?,?)"
    GameDB.exec(sql,
      @forum_id,
      @forum_name,
      @parent.id,
      @forum_post,
      @forum_type,
      @forum_perm,
      @owner_id
    )
  rescue e
    error e
  end

  def vload
    unless @loaded
      load
      children
      @loaded = true
    end
  end
end
