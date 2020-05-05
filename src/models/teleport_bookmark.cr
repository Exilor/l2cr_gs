class TeleportBookmark < Location
  getter id
  property name : String
  property icon : Int32
  property tag : String

  def initialize(id : Int32, x : Int32, y : Int32, z : Int32, icon : Int32, tag : String, name : String)
    super(x, y, z)

    @id = id
    @icon = icon
    @tag = tag
    @name = name
  end
end
