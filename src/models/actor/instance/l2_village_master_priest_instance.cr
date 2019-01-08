require "./l2_village_master_instance"

class L2VillageMasterPriestInstance < L2VillageMasterInstance
  private def check_village_master_race(pclass : PlayerClass?) : Bool
    !!pclass && (pclass.of_race?(Race::HUMAN) || pclass.of_race?(Race::ELF))
  end

  private def check_village_master_teach_type(pclass : PlayerClass?) : Bool
    !!pclass && pclass.of_type?(ClassType::Priest)
  end
end
