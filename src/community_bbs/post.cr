struct Post
  class CPost
    property post_id : Int32 = 0
    property post_owner : String = ""
    property post_owner_id : Int32 = 0
    property post_date : Int64 = 0i64
    property post_topic_id : Int32 = 0
    property post_forum_id : Int32 = 0
    property post_txt : String = ""
  end

  @post = [] of CPost

  def initialize(post_owner : String, post_owner_id : Int32, date : Int64, tid : Int32, post_forum_id : Int32, txt : String)
    cp = CPost.new
    cp.post_owner = post_owner
    cp.post_owner_id = post_owner_id
    cp.post_date = date
    cp.post_topic_id = tid
    cp.post_forum_id = post_forum_id
    cp.post_txt = txt
    @post << cp
    insert_in_db(cp)
  end

  def initialize(t : Topic)
    load(t)
  end

  def insert_in_db(cp : CPost)
    sql = "INSERT INTO posts (post_id,post_owner_name,post_ownerid,post_date,post_topic_id,post_forum_id,post_txt) values (?,?,?,?,?,?,?)"
    GameDB.exec(
      sql,
      cp.post_id,
      cp.post_owner,
      cp.post_owner_id,
      cp.post_date,
      cp.post_topic_id,
      cp.post_forum_id,
      cp.post_txt
    )
  rescue e
    error e
  end

  def get_cp_post(id : Int32) : CPost?
    @post[id]?
  end

  def delete_me(t : Topic)
    PostBBSManager.del_post_by_topic(t)
    sql = "DELETE FROM posts WHERE post_forum_id=? AND post_topic_id=?"
    GameDB.exec(sql, t.forum_id, t.id)
  rescue e
    error e
  end

  private def load(t : Topic)
    sql = "SELECT * FROM posts WHERE post_forum_id=? AND post_topic_id=? ORDER BY post_id ASC"
    GameDB.each(sql, t.forum_id, t.id) do |rs|
      cp = CPost.new
      cp.post_id = rs.get_i32(:"post_id")
      cp.post_owner = rs.get_string(:"post_owner_name")
      cp.post_owner_id = rs.get_i32(:"post_ownerid")
      cp.post_date = rs.get_i64(:"post_date")
      cp.post_topic_id = rs.get_i32(:"post_topic_id")
      post_forum_id = rs.get_i32(:"post_forum_id")
      cp.post_txt = rs.get_string(:"post_txt")
      @post << cp
    end
  rescue e
    error e
  end

  def update_txt(i : Int32)
    cp = get_cp_post(i).not_nil!
    sql = "UPDATE posts SET post_txt=? WHERE post_id=? AND post_topic_id=? AND post_forum_id=?"
    GameDB.exec(sql, cp.post_txt, cp.post_id, cp.post_topic_id, cp.post_forum_id)
  rescue e
    error e
  end
end
