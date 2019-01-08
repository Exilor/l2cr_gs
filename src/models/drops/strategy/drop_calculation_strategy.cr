struct DropCalculationStrategy
  private def initialize(&@proc : GeneralDropItem, L2Character, L2Character -> ItemHolder?)
  end

  def calculate_drops(item : GeneralDropItem, victim : L2Character, killer : L2Character) : ItemHolder?
    @proc.call(item, victim, killer)
  end

  DEFAULT_STRATEGY = new do |item, victim, killer|
    chance = item.get_chance(victim, killer)
    if chance > Rnd.rand * 100
      amount_multiply = 1
      if item.precise_calculated? && chance > 100
        amount_multiply = (chance / 100).to_i
        if chance % 100 > Rnd.rand * 100
          amount_multiply += 1
        end
      end

      min = item.get_min(victim)
      max = item.get_max(victim)
      ItemHolder.new(item.item_id, Rnd.rand(min..max) * amount_multiply)
    end
  end

  def self.parse(name : String) : self
    if name.casecmp?("DEFAULT_STRATEGY")
      return DEFAULT_STRATEGY
    end

    raise "unknown #{self} #{name.inspect}"
  end
end
