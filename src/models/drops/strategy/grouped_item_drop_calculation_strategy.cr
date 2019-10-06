require "../general_drop_item"
require "../grouped_general_drop_item"

struct GroupedItemDropCalculationStrategy
  private SINGLE_ITEM_CACHE = Concurrent::Map(GroupedGeneralDropItem, GeneralDropItem).new

  private def initialize(&@proc : GroupedGeneralDropItem, L2Character, L2Character -> ItemHolder | Array(ItemHolder) | Nil)
  end

  def calculate_drops(item : GroupedGeneralDropItem, victim : L2Character, killer : L2Character) : ItemHolder | Array(ItemHolder) | Nil
    @proc.call(item, victim, killer)
  end

  private def self.default_strategy : self
    new do |item, victim, killer|
      if item.items.size == 1
        next get_single_item(item).calculate_drops(victim, killer)
      end

      value = nil
      normalized = item.normalize_me(victim, killer)
      total_chance = 0.0
      random = Rnd.rand * 100
      if normalized.chance > Rnd.rand * 100
        normalized.items.each do |item2|
          total_chance += item2.chance
          if total_chance > random
            amount_multiply = 1
            if item.precise_calculated? && normalized.chance >= 100
              amount_multiply = (normalized.chance / 100).to_i
              if normalized.chance % 100 > Rnd.rand * 100
                amount_multiply += 1
              end
            end
            value = ItemHolder.new(item2.item_id, Rnd.rand(item2.get_min(victim)..item2.get_max(victim)) * amount_multiply)
            break
          end
        end
      end

      value
    end
  end

  private def self.get_single_item(i : GroupedGeneralDropItem) : GeneralDropItem
    item1 = i.items.first
    SINGLE_ITEM_CACHE.put_if_absent(i) do
      GeneralDropItem.new(
        item1.item_id,
        item1.min,
        item1.max,
        (item1.chance * i.chance) / 100,
        item1.amount_strategy,
        item1.chance_strategy,
        i.precise_strategy,
        i.killer_chance_modifier_strategy,
        item1.drop_calculation_strategy
      )
    end
  end

  DEFAULT_STRATEGY = default_strategy

  DISBAND_GROUP = new do |item, victim, killer|
    dropped = [] of ItemHolder
    item.extract_me.each do |drop_item|
      dropped.concat(drop_item.calculate_drops(victim, killer))
    end
    dropped unless dropped.empty?
  end

  PRECISE_MULTIPLE_GROUP_ROLLS = new do |item, victim, killer|
    unless item.precise_calculated?
      return DEFAULT_STRATEGY.call(item, victim, victim)
    end

    new_item = GroupedGeneralDropItem.new(item.chance, DEFAULT_STRATEGY, item.killer_chance_modifier_strategy, PreciseDeterminationStrategy::NEVER)
    new_item.items = item.items
    normalized = new_item.normalize_me(victim, killer)
    rolls = (normalized.chance / 100).to_i
    if Rnd.rand * 100 < normalized.chance % 100
      rolls += 1
    end
    dropped = [] of ItemHolder
    rolls.times do |i|
      dropped.concat(normalized.calculate_drops(victim, killer))
    end
    dropped unless dropped.empty?
  end

  def self.parse(name : String) : self
    case name.casecmp
    when "default_strategy"
      DEFAULT_STRATEGY
    when "disband_group"
      DISBAND_GROUP
    when "precise_multiple_group_rolls"
      PRECISE_MULTIPLE_GROUP_ROLLS
    else
      raise "Unknown #{self} #{name.inspect}"
    end
  end
end
