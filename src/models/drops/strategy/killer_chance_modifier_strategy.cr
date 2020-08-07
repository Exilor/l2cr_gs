struct KillerChanceModifierStrategy
  private def initialize(&@proc : IDropItem, L2Character, L2Character -> Float64)
  end

  def get_killer_chance_modifier(item : IDropItem, victim : L2Character, killer : L2Character) : Float64
    @proc.call(item, victim, killer)
  end

  DEFAULT_STRATEGY = new do |item, victim, killer|
    if victim.raid? && Config.deepblue_drop_rules_raid
      lvl_diff = victim.level &- killer.level
      next ((lvl_diff * 0.15) + 1).clamp(0.0, 1.0)
    elsif Config.deepblue_drop_rules
      lvl_diff = victim.level &- killer.level
      next Util.map(
        lvl_diff,
        -Config.drop_item_max_level_difference,
        -Config.drop_item_min_level_difference,
        Config.drop_item_min_level_gap_chance,
        100.0
      ) / 100
    end

    1.0
  end

  DEFAULT_NONGROUP_STRATEGY = new do |item, victim, killer|
    if (!victim.raid? && Config.deepblue_drop_rules) || (victim.raid? && Config.deepblue_drop_rules_raid)
      lvl_diff = victim.level &- killer.level
      if item.as(GeneralDropItem).item_id == Inventory::ADENA_ID
        next Util.map(lvl_diff, -Config.drop_adena_max_level_difference, -Config.drop_adena_min_level_difference, Config.drop_adena_min_level_gap_chance, 100.0) / 100
      end
      next Util.map(lvl_diff, -Config.drop_item_max_level_difference, -Config.drop_item_min_level_difference, Config.drop_item_min_level_gap_chance, 100.0) / 100
    end

    1.0
  end

  NO_RULES = new { |item, victim, killer| 1.0 }
end
