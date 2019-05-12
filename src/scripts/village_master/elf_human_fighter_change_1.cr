class Scripts::ElfHumanFighterChange1 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30066, # Pabris
    30288, # Rains
    30373, # Ramos
    32094  # Schule
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE = 8869
  private MEDALLION_OF_WARRIOR = 1145
  private SWORD_OF_RITUAL = 1161
  private BEZIQUES_RECOMMENDATION = 1190
  private ELVEN_KNIGHT_BROOCH = 1204
  private REISAS_RECOMMENDATION = 1217
  # Classes
  private WARRIOR = 1
  private KNIGHT = 4
  private ROGUE = 7
  private ELVEN_KNIGHT = 19
  private ELVEN_SCOUT = 22

  private EVENTS1 = {
    "30066-01.htm", # pabris003h
    "30066-02.htm", # pabris006ha
    "30066-03.htm", # pabris007ha
    "30066-04.htm", # pabris007hat
    "30066-05.htm", # pabris006hb
    "30066-06.htm", # pabris007hb
    "30066-07.htm", # pabris007hbt
    "30066-08.htm", # pabris006hc
    "30066-09.htm", # pabris007hc
    "30066-10.htm", # pabris007hct
    "30066-11.htm", # pabris003e
    "30066-12.htm", # pabris006ea
    "30066-13.htm", # pabris007ea
    "30066-14.htm", # pabris007eat
    "30066-15.htm", # pabris006eb
    "30066-16.htm", # pabris007eb
    "30066-17.htm", # pabris007ebt
    "30288-01.htm", # master_rains003h
    "30288-02.htm", # master_rains006ha
    "30288-03.htm", # master_rains007ha
    "30288-04.htm", # master_rains007hat
    "30288-05.htm", # master_rains006hb
    "30288-06.htm", # master_rains007hb
    "30288-07.htm", # master_rains007hbt
    "30288-08.htm", # master_rains006hc
    "30288-09.htm", # master_rains007hc
    "30288-10.htm", # master_rains007hct
    "30288-11.htm", # master_rains003e
    "30288-12.htm", # master_rains006ea
    "30288-13.htm", # master_rains007ea
    "30288-14.htm", # master_rains007eat
    "30288-15.htm", # master_rains006eb
    "30288-16.htm", # master_rains007eb
    "30288-17.htm", # master_rains007ebt
    "30373-01.htm", # grandmaster_ramos003h
    "30373-02.htm", # grandmaster_ramos006ha
    "30373-03.htm", # grandmaster_ramos007ha
    "30373-04.htm", # grandmaster_ramos007hat
    "30373-05.htm", # grandmaster_ramos006hb
    "30373-06.htm", # grandmaster_ramos007hb
    "30373-07.htm", # grandmaster_ramos007hbt
    "30373-08.htm", # grandmaster_ramos006hc
    "30373-09.htm", # grandmaster_ramos007hc
    "30373-10.htm", # grandmaster_ramos007hct
    "30373-11.htm", # grandmaster_ramos003e
    "30373-12.htm", # grandmaster_ramos006ea
    "30373-13.htm", # grandmaster_ramos007ea
    "30373-14.htm", # grandmaster_ramos007eat
    "30373-15.htm", # grandmaster_ramos006eb
    "30373-16.htm", # grandmaster_ramos007eb
    "30373-17.htm", # grandmaster_ramos007ebt
    "32094-01.htm", # grandmaster_shull003h
    "32094-02.htm", # grandmaster_shull006ha
    "32094-03.htm", # grandmaster_shull007ha
    "32094-04.htm", # grandmaster_shull007hat
    "32094-05.htm", # grandmaster_shull006hb
    "32094-06.htm", # grandmaster_shull007hb
    "32094-07.htm", # grandmaster_shull007hbt
    "32094-08.htm", # grandmaster_shull006hc
    "32094-09.htm", # grandmaster_shull007hc
    "32094-10.htm", # grandmaster_shull007hct
    "32094-11.htm", # grandmaster_shull003e
    "32094-12.htm", # grandmaster_shull006ea
    "32094-13.htm", # grandmaster_shull007ea
    "32094-14.htm", # grandmaster_shull007eat
    "32094-15.htm", # grandmaster_shull006eb
    "32094-16.htm", # grandmaster_shull007eb
    "32094-17.htm"  # grandmaster_shull007ebt
  }

  private EVENTS2 = {"1", "4", "7", "19", "22"}

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    if EVENTS1.includes?(event)
      event
    elsif EVENTS2.includes?(event)
      class_change_requested(pc, npc, event.to_i)
    end
  end

  def on_talk(npc, pc)
    race = pc.race
    in_category = pc.in_category?(CategoryType::FIGHTER_GROUP)

    if in_category && (race.human? || race.elf?)
      if race.human?
        "#{npc.id}-01.htm"
      else
        "#{npc.id}-11.htm"
      end
    else
      "#{npc.id}-18.htm"
    end
  end

  private def class_change_requested(pc, npc, class_id)
    case
    when pc.in_category?(CategoryType::SECOND_CLASS_GROUP)
      "#{npc.id}-19.htm"
    when pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "#{npc.id}-20.htm"
    when pc.in_category?(CategoryType::FOURTH_CLASS_GROUP)
      "30066-41.htm"
    when class_id == WARRIOR && pc.class_id.fighter?
      try_request(pc, npc, WARRIOR, MEDALLION_OF_WARRIOR, 21)
    when class_id == KNIGHT  && pc.class_id.fighter?
      try_request(pc, npc, KNIGHT, SWORD_OF_RITUAL, 25)
    when class_id == ROGUE   && pc.class_id.fighter?
      try_request(pc, npc, ROGUE, BEZIQUES_RECOMMENDATION, 29)
    when class_id == ELVEN_KNIGHT && pc.class_id.elven_fighter?
      try_request(pc, npc, ELVEN_KNIGHT, ELVEN_KNIGHT_BROOCH, 33)
    when class_id == ELVEN_SCOUT  && pc.class_id.elven_fighter?
      try_request(pc, npc, ELVEN_SCOUT, REISAS_RECOMMENDATION, 37)
    end
  end

  private def try_request(pc, npc, klass, item, idx)
    if pc.level < 20
      if has_quest_items?(pc, item)
        "#{npc.id}-#{idx}.htm"
      else
        "#{npc.id}-#{idx + 1}.htm"
      end
    elsif has_quest_items?(pc, item)
      take_items(pc, item, -1)
      pc.class_id = klass
      pc.base_class = klass
      pc.broadcast_user_info
      give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
      "#{npc.id}-#{idx + 2}.htm"
    else
      "#{npc.id}-#{idx + 3}.htm"
    end
  end
end
