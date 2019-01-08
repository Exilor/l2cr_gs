module Locatable
  abstract def x : Int32
  abstract def y : Int32
  abstract def z : Int32
  abstract def heading : Int32
  abstract def instance_id : Int32
  abstract def location : Locatable

  def xyz : {Int32, Int32, Int32}
    {x, y, z}
  end
end
