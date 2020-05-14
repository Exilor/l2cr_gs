class Announcement
  include Loggable
  include IAnnouncement

  private INSERT_QUERY = "INSERT INTO announcements (type, content, author) VALUES (?, ?, ?)"
  private UPDATE_QUERY = "UPDATE announcements SET type = ?, content = ?, author = ? WHERE id = ?"
  private DELETE_QUERY = "DELETE FROM announcements WHERE id = ?"
  getter id : Int32 = 0

  property type : AnnouncementType = AnnouncementType::NORMAL
  property content : String = ""
  property author : String = ""

  getter_initializer type : AnnouncementType, content : String, author : String

  def initialize(rs : ResultSetReader)
    @id = rs.get_i32(:"id")
    @type = AnnouncementType[rs.get_i32("type")]
    @content = rs.get_string(:"content")
    @author = rs.get_string(:"author")
  end

  def valid? : Bool
    true
  end

  def store_me : Bool
    GameDB.exec(INSERT_QUERY, @type.to_i, @content, @author)
    GameDB.query_each("SELECT id FROM announcements ORDER BY id DESC LIMIT 1") do |rs|
      @id = rs.read(Int32)
    end
    true
  rescue e
    error e
    false
  end

  def update_me : Bool
    GameDB.exec(UPDATE_QUERY, @type.to_i, @content, @author, @id)
    true
  rescue e
    error e
    false
  end

  def delete_me : Bool
    GameDB.exec(DELETE_QUERY, @id)
    true
  rescue e
    error e
    false
  end
end
