class EventAnnouncement
  include IAnnouncement

  getter id
  property content : String

  def initialize(@range : Range(Time, Time), @content : String)
    @id = IdFactory.next
  end

  def type : AnnouncementType
    AnnouncementType::EVENT
  end

  def type=(type : AnnouncementType)
    raise "#type= not supported by EventAnnouncement"
  end

  def author : String
    "N/A"
  end

  def author=(author : String)
    raise "#author= not supported by EventAnnouncement"
  end

  def valid? : Bool
    Time.now.between?(@range.begin, @range.end)
  end

  def delete_me : Bool
    IdFactory.release(@id)
    true
  end

  def store_me : Bool
    true
  end

  def update_me : Bool
    raise "#update_me not supported by EventAnnouncement"
  end
end
