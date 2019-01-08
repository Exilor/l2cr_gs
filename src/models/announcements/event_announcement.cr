class EventAnnouncement
  include IAnnouncement

  getter id
  property content : String

  def initialize(@range : Range(Time, Time), @content : String)
    @id = IdFactory.next
  end

  def type
    AnnouncementType::EVENT
  end

  def type=(type : AnnouncementType)
    raise "type= not supported by EventAnnouncement"
  end

  def author
    "N/A"
  end

  def author=(author : String)
    raise "author= not supported by EventAnnouncement"
  end

  def valid? : Bool
    # TODO
    true
  end

  def delete_me
    IdFactory.release(@id)
    true
  end

  def store_me : Bool
    true
  end

  def update_me
    raise "update_me not supported by EventAnnouncement"
  end
end
