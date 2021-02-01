module GameDB
  module ForumDAOMySQLImpl
    extend self
    extend ForumDAO

    private SELECT_FORUMS = "SELECT forum_id, forum_name, forum_post, forum_type, forum_perm, forum_owner_id FROM forums WHERE forum_type = 0"
    private SELECT_FORUM_CHILDREN = "SELECT forum_id, forum_name, forum_post, forum_type, forum_perm, forum_owner_id FROM forums WHERE forum_parent=?"
    private INSERT_FORUM = "INSERT INTO forums (forum_name, forum_parent, forum_post, forum_type, forum_perm, forum_owner_id) VALUES (?,?,?,?,?,?)"

    def forums : Hash(String, Forum)
      forums = {} of String => Forum

      begin
        GameDB.each(SELECT_FORUMS) do |rs|
          forum = Forum.new(
            rs.get_i32(:"forum_id"),
            rs.get_string(:"forum_name"),
            nil,
            ForumType[rs.get_i32(:"forum_type")],
            ForumVisibility[rs.get_i32(:"forum_perm")],
            rs.get_i32(:"forum_owner_id")
          )
          forums[forum.name] = forum

          GameDB.topic.load(forum)

          load_children(forum)
        end
      rescue e
        error e
      end

      forums
    end

    private def load_children(parent : Forum)
      GameDB.each(SELECT_FORUM_CHILDREN, parent.id) do |rs|
        ForumsBBSManager.load(
          rs.get_i32(:"forum_id"),
          rs.get_string(:"forum_name"),
          parent,
          ForumType[rs.get_i32(:"forum_type")],
          ForumVisibility[rs.get_i32(:"forum_perm")],
          rs.get_i32(:"forum_owner_id")
        )
      end
    rescue e
      error e
    end

    def save(forum : Forum)
      GameDB.transaction do |tr|
        id = nil
        tr.each("SELECT MAX(forum_id) FROM forums") { |rs| id = rs.read(Int32) }
        tr.exec(
          INSERT_FORUM,
          forum.name,
          forum.parent.id,
          forum.post,
          forum.type.to_i,
          forum.visibility.to_i,
          forum.owner_id
        )
        tr.each("SELECT MAX(forum_id) FROM forums") do |rs|
          new_id = rs.read(Int32)
          if id != new_id
            forum.id = new_id
          end
        end
      end
    rescue e
      error e
    end
  end
end
