class Scripts::DarkElfChange1 < AbstractNpcAI
  private NPCS = {
    30290, # Xenos
    30297, # Tobias
    30462, # Tronix
    32096  # Helminter
  }

  # Items
  private GAZE_OF_ABYSS = 1244
  private IRON_HEART = 1252
  private DARK_JEWEL = 1261
  private ORB_OF_ABYSS = 1270
  # Rewards
  private SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE = 8869
  # Classes
  private PALUS_KNIGHT = 32
  private ASSASSIN = 35
  private DARK_WIZARD = 39
  private SHILLIEN_ORACLE = 42
  # Misc
  private MIN_LEVEL = 20

  private FILTER1 = {
    "30290-01.htm",
    "30290-02.htm",
    "30290-03.htm",
    "30290-04.htm",
    "30290-05.htm",
    "30290-06.htm",
    "30290-07.htm",
    "30290-08.htm",
    "30290-09.htm",
    "30290-10.htm",
    "30290-11.htm",
    "30290-12.htm",
    "30290-13.htm",
    "30290-14.htm",
    "30297-01.htm",
    "30297-02.htm",
    "30297-03.htm",
    "30297-04.htm",
    "30297-05.htm",
    "30297-06.htm",
    "30297-07.htm",
    "30297-08.htm",
    "30297-09.htm",
    "30297-10.htm",
    "30297-11.htm",
    "30297-12.htm",
    "30297-13.htm",
    "30297-14.htm",
    "30462-01.htm",
    "30462-02.htm",
    "30462-03.htm",
    "30462-04.htm",
    "30462-05.htm",
    "30462-06.htm",
    "30462-07.htm",
    "30462-08.htm",
    "30462-09.htm",
    "30462-10.htm",
    "30462-11.htm",
    "30462-12.htm",
    "30462-13.htm",
    "30462-14.htm",
    "32096-01.htm",
    "32096-02.htm",
    "32096-03.htm",
    "32096-04.htm",
    "32096-05.htm",
    "32096-06.htm",
    "32096-07.htm",
    "32096-08.htm",
    "32096-09.htm",
    "32096-10.htm",
    "32096-11.htm",
    "32096-12.htm",
    "32096-13.htm",
    "32096-14.htm"
  }

  private FILTER2 = {"32", "35", "39", "42"}

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    if FILTER1.includes?(event)
      event
    elsif FILTER2.includes?(event)
      class_change_requested(pc, npc, event.to_i)
    end
  end

  private def class_change_requested(pc, npc, class_id)
    if pc.in_category?(CategoryType::SECOND_CLASS_GROUP)
      "#{npc.id}-15.htm"
    elsif pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "#{npc.id}-16.htm"
    elsif pc.in_category?(CategoryType::FOURTH_CLASS_GROUP)
      "30290-34.htm"
    elsif class_id == PALUS_KNIGHT && pc.class_id.dark_fighter?
      try_change(pc, npc, class_id, GAZE_OF_ABYSS, 17)
    elsif class_id == ASSASSIN && pc.class_id.dark_fighter?
      try_change(pc, npc, class_id, IRON_HEART, 21)
    elsif class_id == DARK_WIZARD && pc.class_id.dark_mage?
      try_change(pc, npc, class_id, DARK_JEWEL, 25)
    elsif class_id == SHILLIEN_ORACLE && pc.class_id.dark_mage?
      try_change(pc, npc, class_id, ORB_OF_ABYSS, 29)
    end
  end

  private def try_change(pc, npc, class_id, item_id, offset)
    if pc.level < MIN_LEVEL
      if has_quest_items?(pc, item_id)
        "#{npc.id}-#{offset}.htm"
      else
        "#{npc.id}-#{offset + 1}.htm"
      end
    elsif has_quest_items?(pc, item_id)
      take_items(pc, item_id, -1)
      pc.class_id = class_id
      pc.base_class = class_id
      pc.broadcast_user_info
      give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
      "#{npc.id}-#{offset + 2}.htm"
    else
      "#{npc.id}-#{offset + 3}.htm"
    end
  end

  def on_talk(npc, pc)
    if pc.race.dark_elf?
      if pc.in_category?(CategoryType::FIGHTER_GROUP)
        "#{npc.id}-01.htm"
      elsif pc.in_category?(CategoryType::MAGE_GROUP)
        "#{npc.id}-08.htm"
      end
    else
      "#{npc.id}-33.htm"
    end
  end
end
