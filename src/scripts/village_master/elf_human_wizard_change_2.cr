class Scripts::ElfHumanWizardChange2 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30115, # Jurek
    30174, # Arkenias
    30176, # Valleria
    30694, # Scraide
    30854, # Drikiyan
    31331, # Valdis
    31755, # Halaster
    31996  # Javier
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  private MARK_OF_SCHOLAR = 2674 # proof11x, proof12x, proof13x, proof21x, proof22x
  private MARK_OF_TRUST = 2734 # proof11y, proof12y, proof13y
  private MARK_OF_MAGUS = 2840 # proof11z, proof21z
  private MARK_OF_WITCHCRAFT = 3307 # proof12z
  private MARK_OF_SUMMONER = 3336 # proof13z, proof22z
  private MARK_OF_LIFE = 3140 # proof21y, proof22y
  # Classes
  private SORCERER = 12
  private NECROMANCER = 13
  private WARLOCK = 14
  private SPELLSINGER = 27
  private ELEMENTAL_SUMMONER = 28

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when "30115-02.htm", # master_lv3_hew003
         "30115-03.htm", # master_lv3_hew006h
         "30115-04.htm", # master_lv3_hew007h
         "30115-05.htm", # master_lv3_hew007ha
         "30115-06.htm", # master_lv3_hew006h
         "30115-07.htm", # master_lv3_hew007h
         "30115-08.htm", # master_lv3_hew007hb
         "30115-09.htm", # master_lv3_hew006h
         "30115-10.htm", # master_lv3_hew007h
         "30115-11.htm", # master_lv3_hew007hc
         "30115-12.htm", # master_lv3_hew003
         "30115-13.htm", # master_lv3_hew006e
         "30115-14.htm", # master_lv3_hew007e
         "30115-15.htm", # master_lv3_hew007ea
         "30115-16.htm", # master_lv3_hew006e
         "30115-17.htm", # master_lv3_hew007e
         "30115-18.htm"  # master_lv3_hew007eb
      event
    when "12", "13", "14", "27", "28"
      class_change_requested(pc, event.to_i)
    end

  end

  private def class_change_requested(pc, class_id)
    if pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "30115-21.htm" # fnYouAreThirdClass
    elsif class_id == SORCERER && pc.class_id.wizard?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_MAGUS)
          "30115-22.htm" # fnLowLevel11
        else
          "30115-23.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_MAGUS)
        take_items(pc, -1, {MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_MAGUS})
        pc.class_id = SORCERER
        pc.base_class = SORCERER
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30115-24.htm" # fnAfterClassChange11
      else
        "30115-25.htm" # fnNoProof11
      end
    elsif class_id == NECROMANCER && pc.class_id.wizard?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_WITCHCRAFT)
          "30115-26.htm" # fnLowLevel12
        else
          "30115-27.htm" # fnLowLevelNoProof12
        end
      elsif has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_WITCHCRAFT)
        take_items(pc, -1, {MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_WITCHCRAFT})
        pc.class_id = NECROMANCER
        pc.base_class = NECROMANCER
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30115-28.htm" # fnAfterClassChange12
      else
        "30115-29.htm" # fnNoProof12
      end
    elsif class_id == WARLOCK && pc.class_id.wizard?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_SUMMONER)
          "30115-30.htm" # fnLowLevel13
        else
          "30115-31.htm" # fnLowLevelNoProof13
        end
      elsif has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_SUMMONER)
        take_items(pc, -1, {MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_SUMMONER})
        pc.class_id = WARLOCK
        pc.base_class = WARLOCK
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30115-32.htm" # fnAfterClassChange13
      else
        "30115-33.htm" # fnNoProof13
      end
    elsif class_id == SPELLSINGER && pc.class_id.elven_wizard?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_MAGUS)
          "30115-34.htm" # fnLowLevel21
        else
          "30115-35.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_MAGUS)
        take_items(pc, -1, {MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_MAGUS})
        pc.class_id = SPELLSINGER
        pc.base_class = SPELLSINGER
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30115-36.htm" # fnAfterClassChange21
      else
        "30115-37.htm" # fnNoProof21
      end
    elsif class_id == ELEMENTAL_SUMMONER && pc.class_id.elven_wizard?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_SUMMONER)
          "30115-38.htm" # fnLowLevel22
        else
          "30115-39.htm" # fnLowLevelNoProof22
        end
      elsif has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_SUMMONER)
        take_items(pc, -1, {MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_SUMMONER})
        pc.class_id = ELEMENTAL_SUMMONER
        pc.base_class = ELEMENTAL_SUMMONER
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30115-40.htm" # fnAfterClassChange22
      else
        "30115-41.htm" # fnNoProof22
      end
    end
  end

  def on_talk(npc, pc)
    if pc.in_category?(CategoryType::WIZARD_GROUP) && pc.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (pc.in_category?(CategoryType::HUMAN_MALL_CLASS) || pc.in_category?(CategoryType::ELF_MALL_CLASS))
      "30115-01.htm" # fnYouAreFourthClass
    elsif pc.in_category?(CategoryType::WIZARD_GROUP) && (pc.in_category?(CategoryType::HUMAN_MALL_CLASS) || pc.in_category?(CategoryType::ELF_MALL_CLASS))
      class_id = pc.class_id
      if class_id.wizard? || class_id.sorceror? || class_id.necromancer? || class_id.warlock?
        "30115-02.htm" # fnClassList1
      elsif class_id.elven_wizard? || class_id.spellsinger? || class_id.elemental_summoner?
        "30115-12.htm" # fnClassList2
      else
        "30115-19.htm" # fnYouAreFirstClass
      end
    else
      "30115-20.htm" # fnClassMismatch
    end
  end
end
