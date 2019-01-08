class EnchantSupportItem < AbstractEnchantItem
  getter? weapon : Bool

  def initialize(set : StatsSet)
    super
    @weapon = item.item_type.as(EtcItemType).scrl_inc_enchant_prop_wp?
  end
end
