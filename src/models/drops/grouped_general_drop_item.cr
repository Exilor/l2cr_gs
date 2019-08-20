struct GroupedGeneralDropItem
  include IDropItem

  getter items = [] of GeneralDropItem

  getter_initializer chance: Float64,
    drop_calculation_strategy: GroupedItemDropCalculationStrategy,
    killer_chance_modifier_strategy: KillerChanceModifierStrategy,
    precise_strategy: PreciseDeterminationStrategy

  def initialize(chance : Float64)
    initialize(
      chance,
      GroupedItemDropCalculationStrategy::DEFAULT_STRATEGY,
      KillerChanceModifierStrategy::DEFAULT_STRATEGY,
      PreciseDeterminationStrategy::DEFAULT
    )
  end

  def items=(items : Array(GeneralDropItem))
    @items.replace(items)
  end

  def extract_me : Array(GeneralDropItem)
    @items.map do |item|
      GeneralDropItem.new(
        item.item_id,
        item.min,
        item.max,
        (item.chance * @chance) / 100,
        item.amount_strategy,
        @precise_strategy,
        @killer_chance_modifier_strategy,
        item.drop_calculation_strategy
      )
    end
  end

  def normalize_me : GroupedGeneralDropItem
    sum_chance = @items.sum(0.0) do |item|
      (item.chance * @chance) / 100
    end

    group = GroupedGeneralDropItem.new(sum_chance, @drop_calculation_strategy, KillerChanceModifierStrategy::NO_RULES, @precise_strategy)
    group.items = @items.map do |item|
      GeneralDropItem.new(
        item.item_id,
        item.min,
        item.max,
        (item.chance * @chance) / sum_chance,
        item.amount_strategy,
        item.chance_strategy,
        item.precise_strategy,
        item.killer_chance_modifier_strategy,
        item.drop_calculation_strategy
      )
    end
    group
  end

  def normalize_me(victim : L2Character, killer : L2Character?) : GroupedGeneralDropItem
    normalize_me(victim, killer, true, 1)
  end

  def normalize_me(victim : L2Character, killer : L2Character?, chance_modifier : Float64) : GroupedGeneralDropItem
    normalize_me(victim, killer, true, chance_modifier)
  end

  def normalize_me(victim : L2Character) : GroupedGeneralDropItem
    normalize_me(victim, nil, false, 1)
  end

  def normalize_me(victim : L2Character, chance_modifier : Float64) : GroupedGeneralDropItem
    normalize_me(victim, nil, false, chance_modifier)
  end

  def normalize_me(victim : L2Character, killer : L2Character?, apply_killer_modifier : Bool, chance_modifier : Float64) : GroupedGeneralDropItem
    if apply_killer_modifier
      chance_modifier *= get_killer_chance_modifier(victim, killer)
    end

    sum_chance = @items.sum(0.0) do |item|
      (item.get_chance(victim) * @chance * chance_modifier) / 100
    end

    group = GroupedGeneralDropItem.new(sum_chance, @drop_calculation_strategy, KillerChanceModifierStrategy::NO_RULES, @precise_strategy)
    items = @items.map do |item|
      GeneralDropItem.new(
        item.item_id,
        item.get_min(victim),
        item.get_max(victim),
        (item.get_chance(victim) * @chance * chance_modifier) / sum_chance,
        AmountMultiplierStrategy::STATIC,
        ChanceMultiplierStrategy::STATIC,
        @precise_strategy,
        KillerChanceModifierStrategy::NO_RULES,
        item.drop_calculation_strategy
      )
    end
    group.items = items
    group
  end

  def calculate_drops(victim : L2Character, killer : L2Character) : ItemHolder | Array(ItemHolder) | Nil
    @drop_calculation_strategy.calculate_drops(self, victim, killer)
  end

  def get_killer_chance_modifier(victim : L2Character, killer : L2Character) : Float64
    @killer_chance_modifier_strategy.get_killer_chance_modifier(self, victim, killer)
  end

  def precise_calculated? : Bool
    @precise_strategy.precise_calculated?(self)
  end
end
