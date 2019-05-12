require "./general_drop_item"
require "./grouped_general_drop_item"

class DropListScope < EnumClass
  private alias DropProc = Int32, Int64, Int64, Float64 -> IDropItem
  private alias GroupedDropProc = Float64 -> GroupedGeneralDropItem

  protected initializer proc: DropProc, group_proc: GroupedDropProc

  add(
    DEATH,
    DropProc.new do |item_id, min, max, chance|
      GeneralDropItem.new(
        item_id,
        min,
        max,
        chance,
        AmountMultiplierStrategy::DROP,
        ChanceMultiplierStrategy::DROP
      )
    end,
    GroupedDropProc.new { |chance| GroupedGeneralDropItem.new(chance) }
  )

  add(
    CORPSE,
    DropProc.new do |item_id, min, max, chance|
      GeneralDropItem.new(
        item_id,
        min,
        max,
        chance,
        AmountMultiplierStrategy::SPOIL,
        ChanceMultiplierStrategy::SPOIL
      )
    end,
    DEATH.@group_proc
  )

  add(
    STATIC,
    DropProc.new do |item_id, min, max, chance|
      GeneralDropItem.new(
        item_id,
        min,
        max,
        chance,
        AmountMultiplierStrategy::STATIC,
        ChanceMultiplierStrategy::STATIC,
        PreciseDeterminationStrategy::ALWAYS,
        KillerChanceModifierStrategy::NO_RULES
      )
    end,
    GroupedDropProc.new do |chance|
      GroupedGeneralDropItem.new(
        chance,
        GroupedItemDropCalculationStrategy::DEFAULT_STRATEGY,
        KillerChanceModifierStrategy::NO_RULES,
        PreciseDeterminationStrategy::ALWAYS
      )
    end
  )

  add(
    QUEST,
    DropProc.new do |item_id, min, max, chance|
      GeneralDropItem.new(
        item_id,
        min,
        max,
        chance,
        AmountMultiplierStrategy::STATIC,
        ChanceMultiplierStrategy::QUEST,
        PreciseDeterminationStrategy::ALWAYS,
        KillerChanceModifierStrategy::NO_RULES
      )
    end,
    STATIC.@group_proc
  )

  def new_drop_item(item_id : Int32, min : Int64, max : Int64, chance : Float64) : IDropItem
    @proc.call(item_id, min, max, chance)
  end

  def new_grouped_drop_item(chance : Float64) : GroupedGeneralDropItem
    @group_proc.call(chance)
  end
end
