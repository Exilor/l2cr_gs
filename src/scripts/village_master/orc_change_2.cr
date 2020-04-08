class Scripts::OrcChange2 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30513, # Penatus
    30681, # Karia
    30704, # Garvarentz
    30865, # Ladanza
    30913, # Tushku
    31288, # Aklan
    31326, # Lambac
    31336, # Rahorakti
    31977  # Shaka
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  private MARK_OF_CHALLENGER = 2627 # proof11x, proof21x
  private MARK_OF_PILGRIM = 2721 # proof31x, proof32x
  private MARK_OF_DUELIST = 2762 # proof21z
  private MARK_OF_WARSPIRIT = 2879 # proof32z
  private MARK_OF_GLORY = 3203 # proof11y, proof21y, proof31y, proof32y
  private MARK_OF_CHAMPION = 3276 # proof11z
  private MARK_OF_LORD = 3390 # proof31z
  # Classes
  private DESTROYER = 46
  private TYRANT = 48
  private OVERLORD = 51
  private WARCRYER = 52

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when "30513-03.htm", # master_lv3_orc006r
         "30513-04.htm", # master_lv3_orc007r
         "30513-05.htm", # master_lv3_orc007ra
         "30513-07.htm", # master_lv3_orc006m
         "30513-08.htm", # master_lv3_orc007m
         "30513-09.htm", # master_lv3_orc007ma
         "30513-10.htm", # master_lv3_orc003
         "30513-11.htm", # master_lv3_orc006s
         "30513-12.htm", # master_lv3_orc007s
         "30513-13.htm", # master_lv3_orc007sa
         "30513-14.htm", # master_lv3_orc006s
         "30513-15.htm", # master_lv3_orc007s
         "30513-16.htm" # master_lv3_orc007sb
      event
    when "46", "48", "51", "52"
      class_change_requested(pc, event.to_i)
    else
      # automatically added
    end

  end

  private def class_change_requested(pc, class_id)
    if pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "30513-19.htm" # fnYouAreThirdClass
    elsif class_id == DESTROYER && pc.class_id.orc_raider?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_CHAMPION)
          "30513-20.htm" # fnLowLevel11
        else
          "30513-21.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_CHAMPION)
        take_items(pc, -1, {MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_CHAMPION})
        pc.class_id = DESTROYER
        pc.base_class = DESTROYER
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30513-22.htm" # fnAfterClassChange11
      else
        "30513-23.htm" # fnNoProof11
      end
    elsif class_id == TYRANT && pc.class_id.orc_monk?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_DUELIST)
          "30513-24.htm" # fnLowLevel21
        else
          "30513-25.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_DUELIST)
        take_items(pc, -1, {MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_DUELIST})
        pc.class_id = TYRANT
        pc.base_class = TYRANT
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30513-26.htm" # fnAfterClassChange21
      else
        "30513-27.htm" # fnNoProof21
      end
    elsif class_id == OVERLORD && pc.class_id.orc_shaman?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_LORD)
          "30513-28.htm" # fnLowLevel31
        else
          "30513-29.htm" # fnLowLevelNoProof31
        end
      elsif has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_LORD)
        take_items(pc, -1, {MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_LORD})
        pc.class_id = OVERLORD
        pc.base_class = OVERLORD
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30513-30.htm" # fnAfterClassChange31
      else
        "30513-31.htm" # fnNoProof31
      end
    elsif class_id == WARCRYER && pc.class_id.orc_shaman?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_WARSPIRIT)
          "30513-32.htm" # fnLowLevel32
        else
          "30513-33.htm" # fnLowLevelNoProof32
        end
      elsif has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_WARSPIRIT)
        take_items(pc, -1, {MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_WARSPIRIT})
        pc.class_id = WARCRYER
        pc.base_class = WARCRYER
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30513-34.htm" # fnAfterClassChange32
      else
        "30513-35.htm" # fnNoProof32
      end
    end
  end

  def on_talk(npc, pc)
    if pc.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (pc.in_category?(CategoryType::ORC_MALL_CLASS) || pc.in_category?(CategoryType::ORC_FALL_CLASS))
      "30513-01.htm" # fnYouAreFourthClass
    elsif pc.in_category?(CategoryType::ORC_MALL_CLASS) || pc.in_category?(CategoryType::ORC_FALL_CLASS)
      class_id = pc.class_id
      if class_id.orc_raider? || class_id.destroyer?
        "30513-02.htm" # fnClassList1
      elsif class_id.orc_monk? || class_id.tyrant?
        "30513-06.htm" # fnClassList2
      elsif class_id.orc_shaman? || class_id.overlord? || class_id.warcryer?
        "30513-10.htm" # fnClassList3
      else
        "30513-17.htm" # fnYouAreFirstClass
      end
    else
      "30513-18.htm" # fnClassMismatch
    end
  end
end