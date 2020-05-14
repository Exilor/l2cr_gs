require "./announcement"

class AutoAnnouncement < Announcement
  private INSERT_QUERY = "INSERT INTO announcements (`type`, `content`, `author`, `initial`, `delay`, `repeat`) VALUES (?, ?, ?, ?, ?, ?)"
  private UPDATE_QUERY = "UPDATE announcements SET `type` = ?, `content` = ?, `author` = ?, `initial` = ?, `delay` = ?, `repeat` = ? WHERE id = ?"

  @task : TaskExecutor::Scheduler::DelayedTask?
  @current_state = 0

  property initial : Int64
  property delay : Int64
  property repeat : Int32 = -1

  def initialize(@type : AnnouncementType, @content : String, @author : String, @initial : Int64, @delay : Int64, @repeat : Int32)
    super(type, content, author)
    restart_me
  end

  def initialize(rs : ResultSetReader)
    super

    @initial = rs.get_i64(:"initial")
    @delay = rs.get_i64(:"delay")
    @repeat = rs.get_i32(:"repeat")

    restart_me
  end

  def store_me
    GameDB.exec(
      INSERT_QUERY,
      type.to_i,
      content,
      author,
      initial,
      delay,
      repeat
    )
    GameDB.query_each("SELECT id FROM announcements ORDER BY id DESC LIMIT 1") do |rs|
      @id = rs.read(Int32)
    end

    true
  rescue e
    error e
    false
  end

  def update_me : Bool
    GameDB.exec(
      UPDATE_QUERY,
      type.to_i,
      content,
      author,
      initial,
      delay,
      repeat,
      id
    )

    true
  rescue e
    error e
    false
  end

  def delete_me
    if task = @task
      unless task.cancelled?
        task.cancel
      end
    end

    super
  end

  def restart_me
    if task = @task
      unless task.cancelled?
        task.cancel
      end
    end

    @current_state = @repeat
    @task = ThreadPoolManager.schedule_general(self, @initial)
  end

  def call
    if @current_state == -1 || @current_state > 0
      content.split(Config::EOL) do |content|
        Broadcast.to_all_online_players(content, type.auto_critical?)
      end

      if @current_state != -1
        @current_state -= 1
      end
    end

    @task = ThreadPoolManager.schedule_general(self, @delay)
  end
end
