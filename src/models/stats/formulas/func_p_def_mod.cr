class FuncPDefMod < AbstractFunction
  private def initialize
    super(Stats::POWER_DEFENCE)
  end

  def calc(effector, effected, skill, value)
    if pc = effector.as?(L2PcInstance)
      inv = pc.inventory
      if pc.transformed?
        transform = pc.transformation
      end

      unless inv.slot_empty?(Inventory::CHEST)
        value -= get_value(pc, Inventory::CHEST, transform)
      end

      unless inv.slot_empty?(Inventory::HEAD)
        value -= get_value(pc, Inventory::HEAD, transform)
      end

      unless inv.slot_empty?(Inventory::FEET)
        value -= get_value(pc, Inventory::FEET, transform)
      end

      unless inv.slot_empty?(Inventory::GLOVES)
        value -= get_value(pc, Inventory::GLOVES, transform)
      end

      unless inv.slot_empty?(Inventory::UNDER)
        value -= get_value(pc, Inventory::UNDER, transform)
      end

      unless inv.slot_empty?(Inventory::CLOAK)
        value -= get_value(pc, Inventory::CLOAK, transform)
      end


      if !inv.legs_slot_empty? || ((chest = inv.chest_slot) && chest.body_part == L2Item::SLOT_FULL_ARMOR)
        value -= get_value(pc, Inventory::LEGS, transform)
      end
    end

    value * effector.level_mod
  end

  private def get_value(pc, slot, transform)
    if transform
      return transform.get_base_def_by_slot(pc, slot)
    end

    pc.template.get_base_def_by_slot(slot)
  end

  INSTANCE = new
end
