class NpcAI::ElfHumanClericChange2 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30120, # Maximilian
    30191, # Hollint
    30857, # Orven
    30905, # Squillari
    31279, # Gregory
    31328, # Innocentin
    31968  # Baryl
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  private MARK_OF_PILGRIM = 2721 # proof11x, proof12x, proof21x
  private MARK_OF_TRUST = 2734 # proof11y, proof12y
  private MARK_OF_HEALER = 2820 # proof11z, proof21z
  private MARK_OF_REFORMER = 2821 # proof12z
  private MARK_OF_LIFE = 3140 # proof21y
  # Classes
  private BISHOP = 16
  private PROPHET = 17
  private ELDER = 30

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, player)
    return unless npc && player

    case event
    when "30120-02.htm", # master_lv3_hec003
         "30120-03.htm", # master_lv3_hec006h
         "30120-04.htm", # master_lv3_hec007h
         "30120-05.htm", # master_lv3_hec007ha
         "30120-06.htm", # master_lv3_hec006h
         "30120-07.htm", # master_lv3_hec007h
         "30120-08.htm", # master_lv3_hec007hb
         "30120-10.htm", # master_lv3_hec006e
         "30120-11.htm", # master_lv3_hec007e
         "30120-12.htm"  # master_lv3_hec007ea
      htmltext = event
    when "16", "17", "30"
      htmltext = class_change_requested(player, event.to_i)
    end

    htmltext
  end

  private def class_change_requested(player, classId)
    if player.in_category?(CategoryType::THIRD_CLASS_GROUP)
      htmltext = "30120-15.htm" # fnYouAreThirdClass
    elsif classId == BISHOP && player.class_id.cleric?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_HEALER)
          htmltext = "30120-16.htm" # fnLowLevel11
        else
          htmltext = "30120-17.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_HEALER)
        take_items(player, -1, {MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_HEALER})
        player.class_id = BISHOP
        player.base_class = BISHOP
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30120-18.htm" # fnAfterClassChange11
      else
        htmltext = "30120-19.htm" # fnNoProof11
      end
    elsif classId == PROPHET && player.class_id.cleric?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_REFORMER)
          htmltext = "30120-20.htm" # fnLowLevel12
        else
          htmltext = "30120-21.htm" # fnLowLevelNoProof12
        end
      elsif has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_REFORMER)
        take_items(player, -1, {MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_REFORMER})
        player.class_id = PROPHET
        player.base_class = PROPHET
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30120-22.htm" # fnAfterClassChange12
      else
        htmltext = "30120-23.htm" # fnNoProof12
      end
    elsif classId == ELDER && player.class_id.oracle?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_LIFE, MARK_OF_HEALER)
          htmltext = "30120-24.htm" # fnLowLevel21
        else
          htmltext = "30120-25.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(player, MARK_OF_PILGRIM, MARK_OF_LIFE, MARK_OF_HEALER)
        take_items(player, -1, {MARK_OF_PILGRIM, MARK_OF_LIFE, MARK_OF_HEALER})
        player.class_id = ELDER
        player.base_class = ELDER
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30120-26.htm" # fnAfterClassChange21
      else
        htmltext = "30120-27.htm" # fnNoProof21
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    if player.in_category?(CategoryType::CLERIC_GROUP) && player.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (player.in_category?(CategoryType::HUMAN_CALL_CLASS) || player.in_category?(CategoryType::ELF_CALL_CLASS))
      htmltext = "30120-01.htm" # fnYouAreFourthClass
    elsif player.in_category?(CategoryType::CLERIC_GROUP) && (player.in_category?(CategoryType::HUMAN_CALL_CLASS) || player.in_category?(CategoryType::ELF_CALL_CLASS))
      classId = player.class_id
      if classId.cleric? || classId.bishop? || classId.prophet?
        htmltext = "30120-02.htm" # fnClassList1
      elsif classId.oracle? || classId.elder?
        htmltext = "30120-09.htm" # fnClassList2
      else
        htmltext = "30120-13.htm" # fnYouAreFirstClass
      end
    else
      htmltext = "30120-14.htm" # fnClassMismatch
    end

    htmltext
  end
end
