require "../interfaces/script_type"

struct DoorRequestHolder
  include ScriptType
  getter_initializer door: L2DoorInstance
end
