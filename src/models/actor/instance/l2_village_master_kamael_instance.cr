require "./l2_village_master_instance"

class L2VillageMasterKamaelInstance < L2VillageMasterInstance
  private def get_subclass_menu(race : Race) : String
    if Config.alt_game_subclass_everywhere || race.kamael?
      return "data/html/villagemaster/SubClass.htm"
    end

    "data/html/villagemaster/SubClass_NoKamael.htm"
  end

  private def subclass_fail : String
    "data/html/villagemaster/SubClass_Fail_Kamael.htm"
  end

  private def check_quests(pc : L2PcInstance) : Bool
    pc.noble? || pc.quest_completed?("Q00234_FatesWhisper") ||
    pc.quest_completed?("Q00236_SeedsOfChaos")
  end

  private def check_village_master_race(pclass : PlayerClass?) : Bool
    return false unless pclass
    pclass.of_race?(Race::KAMAEL)
  end
end
