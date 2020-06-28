class Scripts::ElfHumanClericChange2 < AbstractNpcAI
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

  def on_adv_event(event, npc, pc)
    return unless npc && pc

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
      event
    when "16", "17", "30"
      class_change_requested(pc, event.to_i)
    end

  end

  private def class_change_requested(pc, class_id)
    if pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "30120-15.htm" # fnYouAreThirdClass
    elsif class_id == BISHOP && pc.class_id.cleric?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_HEALER)
          "30120-16.htm" # fnLowLevel11
        else
          "30120-17.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_HEALER)
        take_items(pc, -1, {MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_HEALER})
        pc.class_id = BISHOP
        pc.base_class = BISHOP
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30120-18.htm" # fnAfterClassChange11
      else
        "30120-19.htm" # fnNoProof11
      end
    elsif class_id == PROPHET && pc.class_id.cleric?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_REFORMER)
          "30120-20.htm" # fnLowLevel12
        else
          "30120-21.htm" # fnLowLevelNoProof12
        end
      elsif has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_REFORMER)
        take_items(pc, -1, {MARK_OF_PILGRIM, MARK_OF_TRUST, MARK_OF_REFORMER})
        pc.class_id = PROPHET
        pc.base_class = PROPHET
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30120-22.htm" # fnAfterClassChange12
      else
        "30120-23.htm" # fnNoProof12
      end
    elsif class_id == ELDER && pc.class_id.oracle?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_LIFE, MARK_OF_HEALER)
          "30120-24.htm" # fnLowLevel21
        else
          "30120-25.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_LIFE, MARK_OF_HEALER)
        take_items(pc, -1, {MARK_OF_PILGRIM, MARK_OF_LIFE, MARK_OF_HEALER})
        pc.class_id = ELDER
        pc.base_class = ELDER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30120-26.htm" # fnAfterClassChange21
      else
        "30120-27.htm" # fnNoProof21
      end
    end
  end

  def on_talk(npc, pc)
    if pc.in_category?(CategoryType::CLERIC_GROUP) && pc.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (pc.in_category?(CategoryType::HUMAN_CALL_CLASS) || pc.in_category?(CategoryType::ELF_CALL_CLASS))
      "30120-01.htm" # fnYouAreFourthClass
    elsif pc.in_category?(CategoryType::CLERIC_GROUP) && (pc.in_category?(CategoryType::HUMAN_CALL_CLASS) || pc.in_category?(CategoryType::ELF_CALL_CLASS))
      class_id = pc.class_id
      if class_id.cleric? || class_id.bishop? || class_id.prophet?
        "30120-02.htm" # fnClassList1
      elsif class_id.oracle? || class_id.elder?
        "30120-09.htm" # fnClassList2
      else
        "30120-13.htm" # fnYouAreFirstClass
      end
    else
      "30120-14.htm" # fnClassMismatch
    end
  end
end
