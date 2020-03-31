require "./i_announcement"

class EventAnnouncement
  include IAnnouncement

  getter id : Int32
  property content : String

  def initialize(@range : DateRange, @content : String)
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
    @range.within_range?(Time.now)
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
