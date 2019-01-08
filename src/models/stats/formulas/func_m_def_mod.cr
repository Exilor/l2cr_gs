require "../../../models/actor/instance/l2_pet_instance"

class FuncMDefMod < AbstractFunction
  private def initialize
    super(Stats::MAGIC_DEFENCE)
  end

  def calc(effector, effected, skill, value)
    if effector.player?
      pc = effector.acting_player

      {
        Inventory::LFINGER, Inventory::RFINGER, Inventory::LEAR,
        Inventory::REAR, Inventory::NECK
      }.each do |slot|
        unless pc.inventory.slot_empty?(slot)
          if pc.transformed?
            value -= pc.transformation.get_base_def_by_slot(pc, slot)
          else
            value -= pc.template.get_base_def_by_slot(slot)
          end
        end
      end
    elsif effector.is_a?(L2PetInstance)
      if effector.inventory.get_paperdoll_l2id(Inventory::NECK) != 0
        value -= 13
      end
    end

    value * BaseStats::MEN.calc_bonus(effector) * effector.level_mod
  end

  INSTANCE = new
end
