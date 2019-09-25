# Segfaults on AbstractScript#set_npc_hate_id if it's a struct.
# Error discovered when entering aggro range of Monastery of Silence mobs and
# being checked for wielded weapons.
abstract class AbstractEventReturn
  getter_initializer override : Bool, abort : Bool
end
