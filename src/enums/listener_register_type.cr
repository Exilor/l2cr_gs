# This has thrown arithmetic overflow in a case statement if : UInt8 in
# multithreaded mode
enum ListenerRegisterType : UInt8
  NPC
  ZONE
  ITEM
  CASTLE
  FORTRESS
  OLYMPIAD
  GLOBAL
  GLOBAL_NPCS
  GLOBAL_MONSTERS
  GLOBAL_PLAYERS
end
