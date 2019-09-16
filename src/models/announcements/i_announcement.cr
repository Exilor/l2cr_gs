require "./announcement_type"

module IAnnouncement
  abstract def id : Int32
  abstract def type : AnnouncementType
  abstract def type=(type : AnnouncementType)
  abstract def valid? : Bool
  abstract def content : String
  abstract def content=(content : String)
  abstract def author : String
  abstract def author=(author : String)
end
