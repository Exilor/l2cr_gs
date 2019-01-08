enum MountType : UInt8
  NONE, STRIDER, WYVERN, WOLF

  def self.find_by_npc_id(id : Int) : self
    if CategoryData.in_category?(CategoryType::STRIDER, id)
      STRIDER
    elsif CategoryData.in_category?(CategoryType::WYVERN_GROUP, id)
      WYVERN
    elsif CategoryData.in_category?(CategoryType::WOLF_GROUP, id)
      WOLF
    else
      NONE
    end
  end
end
