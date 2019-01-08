struct AmountMultiplierStrategy
  private def initialize(&@proc : GeneralDropItem, L2Character -> Float64)
  end

  def get_amount_multiplier(item : GeneralDropItem, victim : L2Character) : Float64
    @proc.call(item, victim)
  end

  # Needs to be a proc because Config will not have loaded by the time the
  # constants are declared.
  private def self.default_strategy(&default_multiplier : -> Float32) : self
    new do |item, victim|
      multiplier = 1.0
      if victim.champion?
        if item.item_id == Inventory::ADENA_ID
          multiplier *= Config.champion_adenas_rewards_amount
        else
          multiplier *= Config.champion_rewards_amount
        end
      end

      drop_amount_multiplier = Config.rate_drop_amount_multiplier[item.item_id]?

      if drop_amount_multiplier
        drop_amount_multiplier
      elsif ItemTable[item.item_id].has_ex_immediate_effect?
        Config.rate_herb_drop_amount_multiplier
      elsif victim.raid?
        Config.rate_raid_drop_amount_multiplier
      else
        default_multiplier.call
      end.to_f64 * multiplier
    end
  end

  DROP   = default_strategy { Config.rate_death_drop_amount_multiplier }
  SPOIL  = default_strategy { Config.rate_corpse_drop_amount_multiplier }
  STATIC = new { |item, victim| 1.0 }

  def self.parse(name : String) : self
    case name.casecmp
    when "drop"
      DROP
    when "spoil"
      SPOIL
    when "static"
      STATIC
    else
      raise "unknown #{name}"
    end
  end
end
