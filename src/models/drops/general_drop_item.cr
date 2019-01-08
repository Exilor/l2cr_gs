require "./i_drop_item"
require "./strategy/*"

struct GeneralDropItem
  include IDropItem

  getter_initializer item_id: Int32, min: Int64, max: Int64, chance: Float64,
    amount_strategy: AmountMultiplierStrategy,
    chance_strategy: ChanceMultiplierStrategy,
    precise_strategy: PreciseDeterminationStrategy,
    killer_strategy: KillerChanceModifierStrategy,
    drop_calculation_strategy: DropCalculationStrategy

  def initialize(item_id : Int32, min : Int64, max : Int64, chance : Float64)
    initialize(item_id, min, max, chance, 1, 1)
  end

  def initialize(item_id : Int32, min : Int64, max : Int64, chance : Float64, default_amount_multiplier : Float, default_chance_multiplier : Float)
    initialize(item_id, min, max, default_chance_multiplier, AmountMultiplierStrategy.default_strategy(default_amount_multiplier), ChanceMultiplierStrategy.default_strategy(default_chance_multiplier))
  end

  def initialize(item_id : Int32, min : Int64, max : Int64, chance : Float64, amount_multiplier_strategy : AmountMultiplierStrategy, chance_multiplier_strategy : ChanceMultiplierStrategy)
    initialize(item_id, min, max, chance, amount_multiplier_strategy, chance_multiplier_strategy, PreciseDeterminationStrategy::DEFAULT, KillerChanceModifierStrategy::DEFAULT_NONGROUP_STRATEGY)
  end

  def initialize(item_id : Int32, min : Int64, max : Int64, chance : Float64, amount_multiplier_strategy : AmountMultiplierStrategy, chance_multiplier_strategy : ChanceMultiplierStrategy, precise_strategy : PreciseDeterminationStrategy, killer_strategy : KillerChanceModifierStrategy)
    initialize(item_id, min, max, chance, amount_multiplier_strategy, chance_multiplier_strategy, precise_strategy, killer_strategy, DropCalculationStrategy::DEFAULT_STRATEGY)
  end

  def get_min(victim : L2Character) : Int64
    (@min * get_amount_multiplier(victim)).to_i64
  end

  def get_max(victim : L2Character) : Int64
    (@max * get_amount_multiplier(victim)).to_i64
  end

  def get_chance(victim : L2Character) : Float64
    @chance * get_chance_multiplier(victim)
  end

  def get_chance(victim : L2Character, killer : L2Character) : Float64
    get_killer_chance_modifier(victim, killer) * get_chance(victim)
  end

  def calculate_drops(victim : L2Character, killer : L2Character) : ItemHolder | Array(ItemHolder) | Nil
    @drop_calculation_strategy.calculate_drops(self, victim, killer)
  end

  def precise_calculated? : Bool
    @precise_strategy.precise_calculated?(self)
  end

  def get_killer_chance_modifier(victim : L2Character, killer : L2Character) : Float64
    @killer_strategy.get_killer_chance_modifier(self, victim, killer)
  end

  def get_amount_multiplier(victim : L2Character) : Float64
    @amount_strategy.get_amount_multiplier(self, victim)
  end

  def get_chance_multiplier(victim : L2Character) : Float64
    @chance_strategy.get_chance_multiplier(self, victim)
  end
end
