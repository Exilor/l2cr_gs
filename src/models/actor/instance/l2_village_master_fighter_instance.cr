require "./l2_village_master_instance"

class L2VillageMasterFighterInstance < L2VillageMasterInstance
  private def check_village_master_race(pclass : PlayerClass?) : Bool
    return false unless pclass
    pclass.of_race?(Race::HUMAN) || pclass.of_race?(Race::ELF)
  end

  private def check_village_master_teach_type(pclass : PlayerClass?) : Bool
    return false unless pclass
    pclass.of_type?(ClassType::Fighter)
  end
end
