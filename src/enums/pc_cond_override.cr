enum PcCondOverride : UInt8
  MAX_STATS_VALUE
  ITEM_CONDITIONS
  SKILL_CONDITIONS
  ZONE_CONDITIONS
  CASTLE_CONDITIONS
  FORTRESS_CONDITIONS
  CLANHALL_CONDITIONS
  FLOOD_CONDITIONS
  CHAT_CONDITIONS
  INSTANCE_CONDITIONS
  QUEST_CONDITIONS
  DEATH_PENALTY
  DESTROY_ALL_ITEMS
  SEE_ALL_PLAYERS
  TARGET_ALL
  DROP_ALL_ITEMS

  def description : String
    case self
    when MAX_STATS_VALUE     then "Overrides maximum states conditions"
    when ITEM_CONDITIONS     then "Overrides item usage conditions"
    when SKILL_CONDITIONS    then "Overrides skill usage conditions"
    when ZONE_CONDITIONS     then "Overrides zone conditions"
    when CASTLE_CONDITIONS   then "Overrides castle conditions"
    when FORTRESS_CONDITIONS then "Overrides fortress conditions"
    when CLANHALL_CONDITIONS then "Overrides clan hall conditions"
    when FLOOD_CONDITIONS    then "Overrides floods conditions"
    when CHAT_CONDITIONS     then "Overrides chat conditions"
    when INSTANCE_CONDITIONS then "Overrides instance conditions"
    when QUEST_CONDITIONS    then "Overrides quest conditions"
    when DEATH_PENALTY       then "Overrides death penalty conditions"
    when DESTROY_ALL_ITEMS   then "Overrides item destroy conditions"
    when SEE_ALL_PLAYERS     then "Overrides the conditions to see hidden players"
    when TARGET_ALL          then "Overrides target conditions"
    when DROP_ALL_ITEMS      then "Overrides item drop conditions"
    else raise "Unknown member #{self}"
    end
  end
end
