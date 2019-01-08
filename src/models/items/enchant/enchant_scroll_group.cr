class EnchantScrollGroup
  @rate_groups : Array(EnchantRateItem)?

  getter_initializer id: Int32

  def add_rate_group(group : EnchantRateItem)
    (@rate_groups ||= [] of EnchantRateItem) << group
  end

  def rate_groups : Indexable(EnchantRateItem)
    @rate_groups || Slice(EnchantRateItem).empty
  end

  def get_rate_group(item : L2Item) : EnchantRateItem?
    @rate_groups.try &.find &.validate(item)
  end
end
