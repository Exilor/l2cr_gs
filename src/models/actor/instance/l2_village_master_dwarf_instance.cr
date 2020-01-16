require "./l2_village_master_instance"

class L2VillageMasterDwarfInstance < L2VillageMasterInstance
  private def check_village_master_race(pclass : PlayerClass?) : Bool
    !!pclass && pclass.of_race?(Race::DWARF)
  end
end
