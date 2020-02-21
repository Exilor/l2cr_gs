enum MountType : UInt8
  NONE
  STRIDER
  WYVERN
  WOLF

  def self.find_by_npc_id(id : Int32) : self
    CategoryData.in_category?(CategoryType::STRIDER, id) ? STRIDER :
    CategoryData.in_category?(CategoryType::WYVERN_GROUP, id) ? WYVERN :
    CategoryData.in_category?(CategoryType::WOLF_GROUP, id) ? WOLF : NONE
  end
end
