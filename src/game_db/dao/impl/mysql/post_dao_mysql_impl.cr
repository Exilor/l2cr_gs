module GameDB
  module PostDAOMySQLImpl
    extend self
    extend PostDAO

    private INSERT_POST = "INSERT INTO posts (post_id,post_owner_name,post_ownerid,post_date,post_topic_id,post_forum_id,post_txt) values (?,?,?,?,?,?,?)"
    private DELETE_POST = "DELETE FROM posts WHERE post_forum_id=? AND post_topic_id=?"
    private SELECT_POSTS = "SELECT * FROM posts WHERE post_forum_id=? AND post_topic_id=? ORDER BY post_id"
    private UPDATE_POST = "UPDATE posts SET post_txt=? WHERE post_id=? AND post_topic_id=? AND post_forum_id=?"

    def save(cp : Post)
      GameDB.exec(
        INSERT_POST,
        cp.id,
        cp.owner_name,
        cp.owner_id,
        cp.date,
        cp.topic_id,
        cp.forum_id,
        cp.text
      )
    rescue e
      error e
    end

    def delete(topic : Topic)
      GameDB.exec(DELETE_POST, topic.forum_id, topic.id)
    rescue e
      error e
    end

    def load(topic : Topic) : Array(Post)
      posts = [] of Post

      begin
        GameDB.each(SELECT_POSTS, topic.forum_id, topic.id) do |rs|
          posts << Post.new(
            rs.get_i32(:"post_id"),
            rs.get_i32(:"post_owner_name"),
            rs.get_i64(:"post_date"),
            rs.get_i32(:"post_topic_id"),
            rs.get_i32(:"post_forum_id")
          )
        end
      rescue e
        error e
      end

      posts
    end

    def update(cp : Post)
      GameDB.exec(UPDATE_POST, cp.text, cp.id, cp.topic_id, cp.forum_id)
    rescue e
      error e
    end
  end
end
