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

  def on_adv_event(event, npc, player)
    return unless npc && player

    htmltext = nil
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
      htmltext = event
    when "12", "13", "14", "27", "28"
      htmltext = class_change_requested(player, event.to_i)
    end

    htmltext
  end

  private def class_change_requested(player, classId)
    htmltext = nil
    if player.in_category?(CategoryType::THIRD_CLASS_GROUP)
      htmltext = "30115-21.htm" # fnYouAreThirdClass
    elsif classId == SORCERER && player.class_id.wizard?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_MAGUS)
          htmltext = "30115-22.htm" # fnLowLevel11
        else
          htmltext = "30115-23.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_MAGUS)
        take_items(player, -1, {MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_MAGUS})
        player.class_id = SORCERER
        player.base_class = SORCERER
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30115-24.htm" # fnAfterClassChange11
      else
        htmltext = "30115-25.htm" # fnNoProof11
      end
    elsif classId == NECROMANCER && player.class_id.wizard?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_WITCHCRAFT)
          htmltext = "30115-26.htm" # fnLowLevel12
        else
          htmltext = "30115-27.htm" # fnLowLevelNoProof12
        end
      elsif has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_WITCHCRAFT)
        take_items(player, -1, {MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_WITCHCRAFT})
        player.class_id = NECROMANCER
        player.base_class = NECROMANCER
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30115-28.htm" # fnAfterClassChange12
      else
        htmltext = "30115-29.htm" # fnNoProof12
      end
    elsif classId == WARLOCK && player.class_id.wizard?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_SUMMONER)
          htmltext = "30115-30.htm" # fnLowLevel13
        else
          htmltext = "30115-31.htm" # fnLowLevelNoProof13
        end
      elsif has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_SUMMONER)
        take_items(player, -1, {MARK_OF_SCHOLAR, MARK_OF_TRUST, MARK_OF_SUMMONER})
        player.class_id = WARLOCK
        player.base_class = WARLOCK
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30115-32.htm" # fnAfterClassChange13
      else
        htmltext = "30115-33.htm" # fnNoProof13
      end
    elsif classId == SPELLSINGER && player.class_id.elven_wizard?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_MAGUS)
          htmltext = "30115-34.htm" # fnLowLevel21
        else
          htmltext = "30115-35.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_MAGUS)
        take_items(player, -1, {MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_MAGUS})
        player.class_id = SPELLSINGER
        player.base_class = SPELLSINGER
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30115-36.htm" # fnAfterClassChange21
      else
        htmltext = "30115-37.htm" # fnNoProof21
      end
    elsif classId == ELEMENTAL_SUMMONER && player.class_id.elven_wizard?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_SUMMONER)
          htmltext = "30115-38.htm" # fnLowLevel22
        else
          htmltext = "30115-39.htm" # fnLowLevelNoProof22
        end
      elsif has_quest_items?(player, MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_SUMMONER)
        take_items(player, -1, {MARK_OF_SCHOLAR, MARK_OF_LIFE, MARK_OF_SUMMONER})
        player.class_id = ELEMENTAL_SUMMONER
        player.base_class = ELEMENTAL_SUMMONER
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30115-40.htm" # fnAfterClassChange22
      else
        htmltext = "30115-41.htm" # fnNoProof22
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    htmltext = nil
    if player.in_category?(CategoryType::WIZARD_GROUP) && player.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (player.in_category?(CategoryType::HUMAN_MALL_CLASS) || player.in_category?(CategoryType::ELF_MALL_CLASS))
      htmltext = "30115-01.htm" # fnYouAreFourthClass
    elsif player.in_category?(CategoryType::WIZARD_GROUP) && (player.in_category?(CategoryType::HUMAN_MALL_CLASS) || player.in_category?(CategoryType::ELF_MALL_CLASS))
      classId = player.class_id
      if classId.wizard? || classId.sorceror? || classId.necromancer? || classId.warlock?
        htmltext = "30115-02.htm" # fnClassList1
      elsif classId.elven_wizard? || classId.spellsinger? || classId.elemental_summoner?
        htmltext = "30115-12.htm" # fnClassList2
      else
        htmltext = "30115-19.htm" # fnYouAreFirstClass
      end
    else
      htmltext = "30115-20.htm" # fnClassMismatch
    end

    htmltext
  end
end
