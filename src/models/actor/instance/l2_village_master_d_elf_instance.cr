require "./l2_village_master_instance"

class L2VillageMasterDElfInstance < L2VillageMasterInstance
  private def check_village_master_race(pclass : PlayerClass?) : Bool
    !!pclass && pclass.of_race?(Race::DARK_ELF)
  end
end
