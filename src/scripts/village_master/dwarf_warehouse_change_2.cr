class Scripts::DwarfWarehouseChange2 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30511, # Gesto
    30676, # Croop
    30685, # Baxt
    30845, # Klump
    30894, # Natools
    31269, # Mona
    31314, # Donal
    31958  # Yasheni
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  private MARK_OF_SEARCHER = 2809 # proof11z
  private MARK_OF_GUILDSMAN = 3119 # proof11x
  private MARK_OF_PROSPERITY = 3238 # proof11y
  # Class
  private BOUNTY_HUNTER = 55

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when "30511-03.htm", "30511-04.htm", "30511-05.htm" # master_lv3_ware007fa
      event
    when "55"
      class_change_requested(pc, event.to_i)
    else
      # [automatically added else]
    end

  end

  private def class_change_requested(pc, class_id)
    if pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "30511-08.htm" # fnYouAreThirdClass
    elsif class_id == BOUNTY_HUNTER && pc.class_id.scavenger?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_SEARCHER)
          "30511-09.htm" # fnLowLevel11
        else
          "30511-10.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(pc, MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_SEARCHER)
        take_items(pc, -1, {MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_SEARCHER})
        pc.class_id = BOUNTY_HUNTER
        pc.base_class = BOUNTY_HUNTER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        "30511-11.htm" # fnAfterClassChange11
      else
        "30511-12.htm" # fnNoProof11
      end
    end
  end

  def on_talk(npc, pc)
    if pc.in_category?(CategoryType::FOURTH_CLASS_GROUP) && pc.in_category?(CategoryType::BOUNTY_HUNTER_GROUP)
      "30511-01.htm" # fnYouAreFourthClass
    elsif pc.in_category?(CategoryType::BOUNTY_HUNTER_GROUP)
      class_id = pc.class_id
      if class_id.scavenger? || class_id.bounty_hunter?
        "30511-02.htm" # fnClassList1
      else
        "30511-06.htm" # fnYouAreFirstClass
      end
    else
      "30511-07.htm" # fnClassMismatch
    end
  end
end
