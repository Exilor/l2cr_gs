module IDropItem
  abstract def calculate_drops(victim : L2Character, killer : L2Character) : Slice(ItemHolder)
end
