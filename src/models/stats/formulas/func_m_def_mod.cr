require "../../../models/actor/instance/l2_pet_instance"

class FuncMDefMod < AbstractFunction
  private def initialize
    super(Stats::MAGIC_DEFENCE)
  end

  def calc(effector, effected, skill, value)
    if pc = effector.as?(L2PcInstance)
      inv = pc.inventory
      if pc.transformed?
        transform = pc.transformation
      end

      unless inv.slot_empty?(Inventory::LFINGER)
        value -= get_value(pc, Inventory::LFINGER, transform)
      end

      unless inv.slot_empty?(Inventory::RFINGER)
        value -= get_value(pc, Inventory::RFINGER, transform)
      end

      unless inv.slot_empty?(Inventory::LEAR)
        value -= get_value(pc, Inventory::LEAR, transform)
      end

      unless inv.slot_empty?(Inventory::REAR)
        value -= get_value(pc, Inventory::REAR, transform)
      end

      unless inv.slot_empty?(Inventory::NECK)
        value -= get_value(pc, Inventory::NECK, transform)
      end
    elsif effector.pet?
      if effector.inventory.get_paperdoll_l2id(Inventory::NECK) != 0
        value -= 13
      end
    end

    value * BaseStats::MEN.calc_bonus(effector) * effector.level_mod
  end

  private def get_value(pc, slot, transform)
    if transform
      return transform.get_base_def_by_slot(pc, slot)
    end

    pc.template.get_base_def_by_slot(slot)
  end

  INSTANCE = new
end
