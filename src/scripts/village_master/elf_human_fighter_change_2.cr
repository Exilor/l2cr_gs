class Scripts::ElfHumanFighterChange2 < AbstractNpcAI
  private NPCS = {
    30109, # Hannavalt
    30187, # Klaus
    30689, # Siria
    30849, # Sedrick
    30900, # Marcus
    31276, # Bernhard
    31321, # Siegmund
    31965  # Hector
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  private MARK_OF_CHALLENGER = 2627 # proof11x, proof12x, proof42x
  private MARK_OF_DUTY = 2633 # proof21x, proof22x, proof41x
  private MARK_OF_SEEKER = 2673 # proof31x, proof32x, proof51x, proof52x
  private MARK_OF_TRUST = 2734 # proof11y, proof12y, proof21y, proof22y, proof31y, proof32y
  private MARK_OF_DUELIST = 2762 # proof11z, proof42z
  private MARK_OF_SEARCHER = 2809 # proof31z, proof51z
  private MARK_OF_HEALER = 2820 # proof21z, proof41z
  private MARK_OF_LIFE = 3140 # proof41y, proof42y, proof51y, proof52y
  private MARK_OF_CHAMPION = 3276 # proof12z
  private MARK_OF_SAGITTARIUS = 3293 # proof32z, proof52z
  private MARK_OF_WITCHCRAFT = 3307 # proof22z

  # Classes
  private GLADIATOR = 2
  private WARLORD = 3
  private PALADIN = 5
  private DARK_AVENGER = 6
  private TREASURE_HUNTER = 8
  private HAWKEYE = 9
  private TEMPLE_KNIGHT = 20
  private SWORDSINGER = 21
  private PLAINS_WALKER = 23
  private SILVER_RANGER = 24

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when "30109-02.htm", # master_lv3_hef003
         "30109-03.htm", # master_lv3_hef006w
         "30109-04.htm", # master_lv3_hef007w
         "30109-05.htm", # master_lv3_hef007wa
         "30109-06.htm", # master_lv3_hef006w
         "30109-07.htm", # master_lv3_hef007w
         "30109-08.htm", # master_lv3_hef007wb
         "30109-09.htm", # master_lv3_hef003
         "30109-10.htm", # master_lv3_hef006k
         "30109-11.htm", # master_lv3_hef007k
         "30109-12.htm", # master_lv3_hef007ka
         "30109-13.htm", # master_lv3_hef006k
         "30109-14.htm", # master_lv3_hef007k
         "30109-15.htm", # master_lv3_hef007kb
         "30109-16.htm", # master_lv3_hef003
         "30109-17.htm", # master_lv3_hef006r
         "30109-18.htm", # master_lv3_hef007r
         "30109-19.htm", # master_lv3_hef007ra
         "30109-20.htm", # master_lv3_hef006r
         "30109-21.htm", # master_lv3_hef007r
         "30109-22.htm", # master_lv3_hef007rb
         "30109-23.htm", # master_lv3_hef003
         "30109-24.htm", # master_lv3_hef006e
         "30109-25.htm", # master_lv3_hef007e
         "30109-26.htm", # master_lv3_hef007ea
         "30109-27.htm", # master_lv3_hef006e
         "30109-28.htm", # master_lv3_hef007e
         "30109-29.htm", # master_lv3_hef007eb
         "30109-30.htm", # master_lv3_hef003
         "30109-31.htm", # master_lv3_hef006s
         "30109-32.htm", # master_lv3_hef007s
         "30109-33.htm", # master_lv3_hef007sa
         "30109-34.htm", # master_lv3_hef006s
         "30109-35.htm", # master_lv3_hef007s
         "30109-36.htm"  # master_lv3_hef007sb

      event
    when "2", "3", "5", "6", "8", "9", "20", "21", "23", "24"
      class_change_requested(pc, event.to_i)
    else
      # automatically added
    end

  end

  private def class_change_requested(pc, class_id)
    if pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "30109-39.htm" # fnYouAreThirdClass
    elsif class_id == GLADIATOR && pc.class_id.warrior?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_TRUST, MARK_OF_DUELIST)
          "30109-40.htm" # fnLowLevel11
        else
          "30109-41.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_TRUST, MARK_OF_DUELIST)
        take_items(pc, -1, {MARK_OF_CHALLENGER, MARK_OF_TRUST, MARK_OF_DUELIST})
        pc.class_id = GLADIATOR
        pc.base_class = GLADIATOR
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-42.htm" # fnAfterClassChange11
      else
        "30109-43.htm" # fnNoProof11
      end
    elsif class_id == WARLORD && pc.class_id.warrior?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_TRUST, MARK_OF_CHAMPION)
          "30109-44.htm" # fnLowLevel12
        else
          "30109-45.htm" # fnLowLevelNoProof12
        end
      elsif has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_TRUST, MARK_OF_CHAMPION)
        take_items(pc, -1, {MARK_OF_CHALLENGER, MARK_OF_TRUST, MARK_OF_CHAMPION})
        pc.class_id = WARLORD
        pc.base_class = WARLORD
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-46.htm" # fnAfterClassChange12
      else
        "30109-47.htm" # fnNoProof12
      end
    elsif class_id == PALADIN && pc.class_id.knight?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_TRUST, MARK_OF_HEALER)
          "30109-48.htm" # fnLowLevel21
        else
          "30109-49.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_TRUST, MARK_OF_HEALER)
        take_items(pc, -1, {MARK_OF_DUTY, MARK_OF_TRUST, MARK_OF_HEALER})
        pc.class_id = PALADIN
        pc.base_class = PALADIN
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-50.htm" # fnAfterClassChange21
      else
        "30109-51.htm" # fnNoProof21
      end
    elsif class_id == DARK_AVENGER && pc.class_id.knight?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_TRUST, MARK_OF_WITCHCRAFT)
          "30109-52.htm" # fnLowLevel22
        else
          "30109-53.htm" # fnLowLevelNoProof22
        end
      elsif has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_TRUST, MARK_OF_WITCHCRAFT)
        take_items(pc, -1, {MARK_OF_DUTY, MARK_OF_TRUST, MARK_OF_WITCHCRAFT})
        pc.class_id = DARK_AVENGER
        pc.base_class = DARK_AVENGER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-54.htm" # fnAfterClassChange22
      else
        "30109-55.htm" # fnNoProof22
      end
    elsif class_id == TREASURE_HUNTER && pc.class_id.rogue?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_TRUST, MARK_OF_SEARCHER)
          "30109-56.htm" # fnLowLevel31
        else
          "30109-57.htm" # fnLowLevelNoProof31
        end
      elsif has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_TRUST, MARK_OF_SEARCHER)
        take_items(pc, -1, {MARK_OF_SEEKER, MARK_OF_TRUST, MARK_OF_SEARCHER})
        pc.class_id = TREASURE_HUNTER
        pc.base_class = TREASURE_HUNTER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-58.htm" # fnAfterClassChange31
      else
        "30109-59.htm" # fnNoProof31
      end
    elsif class_id == HAWKEYE && pc.class_id.rogue?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_TRUST, MARK_OF_SAGITTARIUS)
          "30109-60.htm" # fnLowLevel32
        else
          "30109-61.htm" # fnLowLevelNoProof32
        end
      elsif has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_TRUST, MARK_OF_SAGITTARIUS)
        take_items(pc, -1, {MARK_OF_SEEKER, MARK_OF_TRUST, MARK_OF_SAGITTARIUS})
        pc.class_id = HAWKEYE
        pc.base_class = HAWKEYE
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-62.htm" # fnAfterClassChange32
      else
        "30109-63.htm" # fnNoProof32
      end
    elsif class_id == TEMPLE_KNIGHT && pc.class_id.elven_knight?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_LIFE, MARK_OF_HEALER)
          "30109-64.htm" # fnLowLevel41
        else
          "30109-65.htm" # fnLowLevelNoProof41
        end
      elsif has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_LIFE, MARK_OF_HEALER)
        take_items(pc, -1, {MARK_OF_DUTY, MARK_OF_LIFE, MARK_OF_HEALER})
        pc.class_id = TEMPLE_KNIGHT
        pc.base_class = TEMPLE_KNIGHT
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-66.htm" # fnAfterClassChange41
      else
        "30109-67.htm" # fnNoProof41
      end
    elsif class_id == SWORDSINGER && pc.class_id.elven_knight?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_LIFE, MARK_OF_DUELIST)
          "30109-68.htm" # fnLowLevel42
        else
          "30109-69.htm" # fnLowLevelNoProof42
        end
      elsif has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_LIFE, MARK_OF_DUELIST)
        take_items(pc, -1, {MARK_OF_CHALLENGER, MARK_OF_LIFE, MARK_OF_DUELIST})
        pc.class_id = SWORDSINGER
        pc.base_class = SWORDSINGER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-70.htm" # fnAfterClassChange42
      else
        "30109-71.htm" # fnNoProof42
      end
    elsif class_id == PLAINS_WALKER && pc.class_id.elven_scout?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_LIFE, MARK_OF_SEARCHER)
          "30109-72.htm" # fnLowLevel51
        else
          "30109-73.htm" # fnLowLevelNoProof51
        end
      elsif has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_LIFE, MARK_OF_SEARCHER)
        take_items(pc, -1, {MARK_OF_SEEKER, MARK_OF_LIFE, MARK_OF_SEARCHER})
        pc.class_id = PLAINS_WALKER
        pc.base_class = PLAINS_WALKER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-74.htm" # fnAfterClassChange51
      else
        "30109-75.htm" # fnNoProof51
      end
    elsif class_id == SILVER_RANGER && pc.class_id.elven_scout?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_LIFE, MARK_OF_SAGITTARIUS)
          "30109-76.htm" # fnLowLevel52
        else
          "30109-77.htm" # fnLowLevelNoProof52
        end
      elsif has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_LIFE, MARK_OF_SAGITTARIUS)
        take_items(pc, -1, {MARK_OF_SEEKER, MARK_OF_LIFE, MARK_OF_SAGITTARIUS})
        pc.class_id = SILVER_RANGER
        pc.base_class = SILVER_RANGER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30109-78.htm" # fnAfterClassChange52
      else
        "30109-79.htm" # fnNoProof52
      end
    end
  end

  def on_talk(npc, pc)
    if pc.in_category?(CategoryType::FIGHTER_GROUP) && pc.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (pc.in_category?(CategoryType::HUMAN_FALL_CLASS) || pc.in_category?(CategoryType::ELF_FALL_CLASS))
      "30109-01.htm" # fnYouAreFourthClass
    elsif pc.in_category?(CategoryType::FIGHTER_GROUP) && (pc.in_category?(CategoryType::HUMAN_FALL_CLASS) || pc.in_category?(CategoryType::ELF_FALL_CLASS))
      class_id = pc.class_id
      if class_id.warrior? || class_id.gladiator? || class_id.warlord?
        "30109-02.htm" # fnClassList1
      elsif class_id.knight? || class_id.paladin? || class_id.dark_avenger?
        "30109-09.htm" # fnClassList2
      elsif class_id.rogue? || class_id.treasure_hunter? || class_id.hawkeye?
        "30109-16.htm" # fnClassList3
      elsif class_id.elven_knight? || class_id.temple_knight? || class_id.sword_singer?
        "30109-23.htm" # fnClassList4
      elsif class_id.elven_scout? || class_id.plains_walker? || class_id.silver_ranger?
        "30109-30.htm" # fnClassList5
      else
        "30109-37.htm" # fnYouAreFirstClass
      end
    else
      "30109-38.htm" # fnClassMismatch
    end
  end
end