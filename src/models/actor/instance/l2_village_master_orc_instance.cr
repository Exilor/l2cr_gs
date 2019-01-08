require "./l2_village_master_instance"

class L2VillageMasterOrcInstance < L2VillageMasterInstance
  private def check_village_master_race(pclass : PlayerClass?) : Bool
    return false unless pclass
    pclass.of_race?(Race::ORC)
  end
end
