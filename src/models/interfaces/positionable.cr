require "./locatable"

module Positionable
  include Locatable

  abstract def x=(x : Int32)
  abstract def y=(y : Int32)
  abstract def z=(z : Int32)
  abstract def heading=(heading : Int32)
  abstract def instance_id=(instance_id : Int32)
  abstract def location=(location : Location)
  abstract def set_xyz(x : Int32, y : Int32, z : Int32)
end
