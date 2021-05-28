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
    when MAX_STATS_VALUE
      "Overrides maximum stats conditions"
    when ITEM_CONDITIONS
      "Overrides item usage conditions"
    when SKILL_CONDITIONS
      "Overrides skill usage conditions"
    when ZONE_CONDITIONS
      "Overrides zone conditions"
    when CASTLE_CONDITIONS
      "Overrides castle conditions"
    when FORTRESS_CONDITIONS
      "Overrides fortress conditions"
    when CLANHALL_CONDITIONS
      "Overrides clan hall conditions"
    when FLOOD_CONDITIONS
      "Overrides floods conditions"
    when CHAT_CONDITIONS
      "Overrides chat conditions"
    when INSTANCE_CONDITIONS
      "Overrides instance conditions"
    when QUEST_CONDITIONS
      "Overrides quest conditions"
    when DEATH_PENALTY
      "Overrides death penalty conditions"
    when DESTROY_ALL_ITEMS
      "Overrides item destroy conditions"
    when SEE_ALL_PLAYERS
      "Overrides the conditions to see hidden players"
    when TARGET_ALL
      "Overrides target conditions"
    else
      "Overrides item drop conditions"
    end
  end
end
