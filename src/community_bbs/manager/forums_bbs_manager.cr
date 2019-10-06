require "./base_bbs_manager"

module ForumsBBSManager
  extend self
  extend BaseBBSManager
  extend Loggable

  private TABLE = Concurrent::Array(Forum).new

  @@last_id = 1

  def load
    sql = "SELECT forum_id FROM forums WHERE forum_type = 0"
    GameDB.each(sql) do |rs|
      forum_id = rs.get_i32("forum_id")
      f = Forum.new(forum_id, nil)
      add_forum(f)
    end
  rescue e
    error e
  end

  def init_root
    TABLE.each &.vload
    info { "Loaded #{TABLE.size} forums. Last forum id used: #{@@last_id}." }
  end

  def add_forum(f : Forum)
    TABLE << f

    if f.id > @@last_id
      @@last_id = f.id
    end
  end

  def parse_cmd(command : String, pc : L2PcInstance)
    # no-op
  end

  def get_forum_by_name(name : String) : Forum?
    TABLE.find { |f| f.name == name }
  end

  def create_new_forum(name : String, parent : Forum, type : Int32, perm : Int32, oid : Int32) : Forum
    forum = Forum.new(name, parent, type, perm, oid)
    forum.insert_into_db
    forum
  end

  def get_new_id
    ret = @@last_id
    @@last_id += 1
    ret
  end

  def get_forum_by_id(id : Int32) : Forum?
    TABLE.find { |f| f.id == id }
  end

  def parse_write(a1 : String, a2 : String, a3 : String, a4 : String, a6 : String, pc : L2PcInstance)
    # no-op
  end
end
