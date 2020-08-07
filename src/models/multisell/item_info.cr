struct Multisell::ItemInfo
  getter enchant_level, augment_id, element_power, elementals, element_id

  def initialize(item : L2ItemInstance)
    @enchant_level = item.enchant_level
    @augment_id = item.augmentation.try &.augmentation_id || 0
    @element_id = item.attack_element_type.to_i8
    @element_power = item.attack_element_power
    @elementals = {
      item.get_element_def_attr(Elementals::FIRE),
      item.get_element_def_attr(Elementals::WATER),
      item.get_element_def_attr(Elementals::WIND),
      item.get_element_def_attr(Elementals::EARTH),
      item.get_element_def_attr(Elementals::HOLY),
      item.get_element_def_attr(Elementals::DARK)
    }
  end

  def initialize(enchant_level : Int32)
    @enchant_level = enchant_level
    @augment_id = 0
    @element_id = Elementals::NONE
    @element_power = 0
    @elementals = {0, 0, 0, 0, 0, 0}
  end
end
