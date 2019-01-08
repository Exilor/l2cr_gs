struct ChanceMultiplierStrategy
  private def initialize(&@proc : GeneralDropItem, L2Character -> Float64)
  end

  def get_chance_multiplier(item : GeneralDropItem, victim : L2Character) : Float64
    @proc.call(item, victim)
  end

  private def self.default_strategy(&default_multiplier : -> Float32) : self
    new do |item, victim|
      multiplier = 1.0
      item_id = item.item_id

      if victim.champion?
        if item_id == Inventory::ADENA_ID
          multiplier *= Config.champion_adenas_rewards_chance
        else
          multiplier *=  Config.champion_rewards_chance
        end
      end

      drop_chance_multiplier = Config.rate_drop_chance_multiplier[item_id]?

      if drop_chance_multiplier
        drop_chance_multiplier
      elsif ItemTable[item_id].has_ex_immediate_effect?
        Config.rate_herb_drop_chance_multiplier
      elsif victim.raid?
        Config.rate_raid_drop_chance_multiplier
      else
        default_multiplier.call
      end.to_f64 * multiplier
    end
  end

  DROP   = default_strategy { Config.rate_death_drop_chance_multiplier }
  SPOIL  = default_strategy { Config.rate_corpse_drop_chance_multiplier }
  STATIC = new { |item, victim| 1.0 }
  QUEST  = new do |item, victim|
    if Config.champion_enable && victim.champion?
      id = item.item_id
      if id == Inventory::ADENA_ID || id == Inventory::ANCIENT_ADENA_ID
        champion_mult = Config.champion_adenas_rewards_chance
      else
        champion_mult = Config.champion_rewards_chance
      end

      Config.rate_quest_drop * champion_mult
    else
      Config.rate_quest_drop
    end.to_f64
  end

  def self.parse(name : String) : self
    case name.casecmp
    when "drop"
      DROP
    when "spoil"
      SPOIL
    when "static"
      STATIC
    when "quest"
      QUEST
    else
      raise "unknown #{self} #{name.inspect}"
    end
  end
end
