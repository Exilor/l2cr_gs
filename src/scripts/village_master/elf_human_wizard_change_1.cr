class Scripts::ElfHumanWizardChange1 < AbstractNpcAI
  private NPCS = {
    30037, # Levian
    30070, # Sylvain
    30289, # Raymond
    32095, # Marie
    32098  # Celes
  }

  private FILTER_1 = {
    "30037-01.htm", # levian003h
    "30037-02.htm", # levian006ha
    "30037-03.htm", # levian007ha
    "30037-04.htm", # levian007hat
    "30037-05.htm", # levian006hb
    "30037-06.htm", # levian007hb
    "30037-07.htm", # levian007hbt
    "30037-08.htm", # levian003e
    "30037-09.htm", # levian006ea
    "30037-10.htm", # levian007ea
    "30037-11.htm", # levian007eat
    "30037-12.htm", # levian006eb
    "30037-13.htm", # levian007eb
    "30037-14.htm", # levian007ebt
    "30070-01.htm", # sylvain003h
    "30070-02.htm", # sylvain006ha
    "30070-03.htm", # sylvain007ha
    "30070-04.htm", # sylvain007hat
    "30070-05.htm", # sylvain006hb
    "30070-06.htm", # sylvain007hb
    "30070-07.htm", # sylvain007hbt
    "30070-08.htm", # sylvain003e
    "30070-09.htm", # sylvain006ea
    "30070-10.htm", # sylvain007ea
    "30070-11.htm", # sylvain007eat
    "30070-12.htm", # sylvain006eb
    "30070-13.htm", # sylvain007eb
    "30070-14.htm", # sylvain007ebt
    "30289-01.htm", # bishop_raimund003h
    "30289-02.htm", # bishop_raimund006ha
    "30289-03.htm", # bishop_raimund007ha
    "30289-04.htm", # bishop_raimund007hat
    "30289-05.htm", # bishop_raimund006hb
    "30289-06.htm", # bishop_raimund007hb
    "30289-07.htm", # bishop_raimund007hbt
    "30289-08.htm", # bishop_raimund003e
    "30289-09.htm", # bishop_raimund006ea
    "30289-10.htm", # bishop_raimund007ea
    "30289-11.htm", # bishop_raimund007eat
    "30289-12.htm", # bishop_raimund006eb
    "30289-13.htm", # bishop_raimund007eb
    "30289-14.htm", # bishop_raimund007ebt
    "32095-01.htm", # highpriest_mattew003h
    "32095-02.htm", # highpriest_mattew006ha
    "32095-03.htm", # highpriest_mattew007ha
    "32095-04.htm", # highpriest_mattew007hat
    "32095-05.htm", # highpriest_mattew006hb
    "32095-06.htm", # highpriest_mattew007hb
    "32095-07.htm", # highpriest_mattew007hbt
    "32095-08.htm", # highpriest_mattew003e
    "32095-09.htm", # highpriest_mattew006ea
    "32095-10.htm", # highpriest_mattew007ea
    "32095-11.htm", # highpriest_mattew007eat
    "32095-12.htm", # highpriest_mattew006eb
    "32095-13.htm", # highpriest_mattew007eb
    "32095-14.htm", # highpriest_mattew007ebt
    "32098-01.htm", # grandmagister_celes003h
    "32098-02.htm", # grandmagister_celes006ha
    "32098-03.htm", # grandmagister_celes007ha
    "32098-04.htm", # grandmagister_celes007hat
    "32098-05.htm", # grandmagister_celes006hb
    "32098-06.htm", # grandmagister_celes007hb
    "32098-07.htm", # grandmagister_celes007hbt
    "32098-08.htm", # grandmagister_celes003e
    "32098-09.htm", # grandmagister_celes006ea
    "32098-10.htm", # grandmagister_celes007ea
    "32098-11.htm", # grandmagister_celes007eat
    "32098-12.htm", # grandmagister_celes006eb
    "32098-13.htm", # grandmagister_celes007eb
    "32098-14.htm"  # grandmagister_celes007ebt
  }

  private FILTER_2 = {"11", "15", "26", "29"}

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE = 8869
  private MARK_OF_FAITH = 1201
  private ETERNITY_DIAMOND = 1230
  private LEAF_OF_ORACLE = 1235
  private BEAD_OF_SEASON = 1292
  # Classes
  private WIZARD = 11
  private CLERIC = 15
  private ELVEN_WIZARD = 26
  private ORACLE = 29

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    if FILTER_1.includes?(event)
      event
    elsif FILTER_2.includes?(event)
      class_change_requested(pc, npc, event.to_i)
    end
  end

  def on_talk(npc, pc)
    race = pc.race
    if pc.in_category?(CategoryType::MAGE_GROUP) && (race.human? || race.elf?)
      if race.human?
        "#{npc.id}-01.htm"
      else
        "#{npc.id}-08.htm"
      end
    else
      "#{npc.id}-15.htm"
    end
  end

  private def class_change_requested(pc, npc, class_id)
    if pc.in_category?(CategoryType::SECOND_CLASS_GROUP)
      "#{npc.id}-16.htm"
    elsif pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "#{npc.id}-17.htm"
    elsif pc.in_category?(CategoryType::FOURTH_CLASS_GROUP)
      "30037-34.htm"
    elsif class_id  == WIZARD && pc.class_id.mage?
      try_request(pc, npc, class_id, BEAD_OF_SEASON, WIZARD, 18)
    elsif class_id == CLERIC && pc.class_id.mage?
      try_request(pc, npc, class_id, MARK_OF_FAITH, CLERIC, 22)
    elsif class_id == ELVEN_WIZARD && pc.class_id.elven_mage?
      try_request(pc, npc, class_id, ETERNITY_DIAMOND, ELVEN_WIZARD, 26)
    elsif class_id == ORACLE && pc.class_id.elven_mage?
      try_request(pc, npc, class_id, LEAF_OF_ORACLE, ORACLE, 30)
    end
  end

  private def try_request(pc, npc, class_id, item, klass, htm_idx)
    if pc.level < 20
      if has_quest_items?(pc, item)
        "#{npc.id}-#{htm_idx}.htm"
      else
        "#{npc.id}-#{htm_idx + 1}.htm"
      end
    elsif has_quest_items?(pc, item)
      take_items(pc, item, -1)
      pc.class_id = klass
      pc.base_class = klass
      pc.broadcast_user_info
      give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
      "#{npc.id}-#{htm_idx + 2}.htm"
    else
      "#{npc.id}-#{htm_idx + 3}.htm"
    end
  end
end
