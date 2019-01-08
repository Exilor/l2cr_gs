class NpcAI::OrcChange2 < AbstractNpcAI
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

  def on_adv_event(event, npc, player)
    return unless npc && player

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
      htmltext = event
    when "46", "48", "51", "52"
      htmltext = class_change_requested(player, event.to_i)
    end

    return htmltext
  end

  private def class_change_requested(player, class_id)
    if player.in_category?(CategoryType::THIRD_CLASS_GROUP)
      htmltext = "30513-19.htm" # fnYouAreThirdClass
    elsif class_id == DESTROYER && player.class_id.orc_raider?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_CHAMPION)
          htmltext = "30513-20.htm" # fnLowLevel11
        else
          htmltext = "30513-21.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(player, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_CHAMPION)
        take_items(player, -1, {MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_CHAMPION})
        player.class_id = DESTROYER
        player.base_class = DESTROYER
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30513-22.htm" # fnAfterClassChange11
      else
        htmltext = "30513-23.htm" # fnNoProof11
      end
    elsif class_id == TYRANT && player.class_id.orc_monk?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_DUELIST)
          htmltext = "30513-24.htm" # fnLowLevel21
        else
          htmltext = "30513-25.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(player, MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_DUELIST)
        take_items(player, -1, {MARK_OF_CHALLENGER, MARK_OF_GLORY, MARK_OF_DUELIST})
        player.class_id = TYRANT
        player.base_class = TYRANT
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30513-26.htm" # fnAfterClassChange21
      else
        htmltext = "30513-27.htm" # fnNoProof21
      end
    elsif class_id == OVERLORD && player.class_id.orc_shaman?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_LORD)
          htmltext = "30513-28.htm" # fnLowLevel31
        else
          htmltext = "30513-29.htm" # fnLowLevelNoProof31
        end
      elsif has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_LORD)
        take_items(player, -1, {MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_LORD})
        player.class_id = OVERLORD
        player.base_class = OVERLORD
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30513-30.htm" # fnAfterClassChange31
      else
        htmltext = "30513-31.htm" # fnNoProof31
      end
    elsif class_id == WARCRYER && player.class_id.orc_shaman?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_WARSPIRIT)
          htmltext = "30513-32.htm" # fnLowLevel32
        else
          htmltext = "30513-33.htm" # fnLowLevelNoProof32
        end
      elsif has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_WARSPIRIT)
        take_items(player, -1, {MARK_OF_PILGRIM, MARK_OF_GLORY, MARK_OF_WARSPIRIT})
        player.class_id = WARCRYER
        player.base_class = WARCRYER
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30513-34.htm" # fnAfterClassChange32
      else
        htmltext = "30513-35.htm" # fnNoProof32
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    if player.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (player.in_category?(CategoryType::ORC_MALL_CLASS) || player.in_category?(CategoryType::ORC_FALL_CLASS))
      htmltext = "30513-01.htm" # fnYouAreFourthClass
    elsif player.in_category?(CategoryType::ORC_MALL_CLASS) || player.in_category?(CategoryType::ORC_FALL_CLASS)
      class_id = player.class_id
      if class_id.orc_raider? || class_id.destroyer?
        htmltext = "30513-02.htm" # fnClassList1
      elsif class_id.orc_monk? || class_id.tyrant?
        htmltext = "30513-06.htm" # fnClassList2
      elsif class_id.orc_shaman? || class_id.overlord? || class_id.warcryer?
        htmltext = "30513-10.htm" # fnClassList3
      else
        htmltext = "30513-17.htm" # fnYouAreFirstClass
      end
    else
      htmltext = "30513-18.htm" # fnClassMismatch
    end

    htmltext
  end
end
