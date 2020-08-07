struct EnchantScrollGroup
  @rate_groups = [] of EnchantRateItem

  getter_initializer id : Int32

  def add_rate_group(group : EnchantRateItem)
    @rate_groups << group
  end

  def rate_groups : Array(EnchantRateItem)
    @rate_groups
  end

  def get_rate_group(item : L2Item) : EnchantRateItem?
    @rate_groups.find &.validate(item)
  end
end
