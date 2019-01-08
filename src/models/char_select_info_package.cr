class CharSelectInfoPackage
  property name : String
  property l2id : Int32
  property exp : Int64 = 0i64
  property sp : Int32 = 0
  property clan_id : Int32 = 0
  property base_class_id : Int32 = 0
  property race : Int32 = 0
  property delete_time : Int64 = 0i64
  property last_access : Int64 = 0i64
  property face : Int32 = 0
  property hair_style : Int32 = 0
  property hair_color : Int32 = 0
  property sex : Int32 = 0
  property level : Int32 = 0
  property max_hp : Int32 = 0
  property current_hp : Float64 = 0.0
  property max_mp : Int32 = 0
  property current_mp : Float64 = 0.0
  property paperdoll : Slice(Slice(Int32))
  property karma : Int32 = 0
  property pk_kills : Int32 = 0
  property pvp_kills : Int32 = 0
  property x : Int32 = 0
  property y : Int32 = 0
  property z : Int32 = 0
  property vitality_points : Int32 = 0
  property access_level : Int32 = 0
  property class_id : Int32 = 0
  property augmentation_id : Int32 = 0
  property html_prefix : String?


  def initialize(@l2id : Int32, @name : String)
    @paperdoll = PcInventory.restore_visible_inventory(@l2id)
  end

  def get_paperdoll_l2id(slot : Int) : Int32
    @paperdoll[slot][0]
  end

  def get_paperdoll_item_id(slot : Int) : Int32
    @paperdoll[slot][1]
  end

  def enchant_effect : Int32
    @paperdoll[Inventory::RHAND][2]
  end
end
