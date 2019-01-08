class FuncPDefMod < AbstractFunction
  private def initialize
    super(Stats::POWER_DEFENCE)
  end

  def calc(effector, effected, skill, value)
    if effector.player?
      pc = effector.acting_player
      {
        Inventory::CHEST, Inventory::HEAD, Inventory::FEET, Inventory::UNDER,
        Inventory::CLOAK
      }.each do |slot|
        unless pc.inventory.slot_empty?(slot)
          value -=
            if pc.transformed?
              pc.transformation.get_base_def_by_slot(pc, slot)
            else
              pc.template.get_base_def_by_slot(slot)
            end
        end
      end

      if !pc.inventory.legs_slot_empty? ||
        !pc.inventory.chest_slot_empty? &&
        pc.inventory.chest_slot.body_part == L2Item::SLOT_FULL_ARMOR

        if pc.transformed?
          value -= pc.transformation.get_base_def_by_slot(pc, Inventory::LEGS)
        else
          value -= pc.template.get_base_def_by_slot(Inventory::LEGS)
        end
      end
    end

    value * effector.level_mod
  end

  INSTANCE = new
end
