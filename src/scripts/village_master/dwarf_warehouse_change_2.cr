class NpcAI::DwarfWarehouseChange2 < AbstractNpcAI
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

  def on_adv_event(event, npc, player)
    return unless npc && player

    case event
    when "30511-03.htm", "30511-04.htm", "30511-05.htm" # master_lv3_ware007fa
      htmltext = event
    when "55"
      htmltext = class_change_requested(player, event.to_i)
    end

    return htmltext
  end

  private def class_change_requested(player, class_id)
    if player.in_category?(CategoryType::THIRD_CLASS_GROUP)
      htmltext = "30511-08.htm" # fnYouAreThirdClass
    elsif class_id == BOUNTY_HUNTER && player.class_id.scavenger?
      if player.level < 40
        if has_quest_items?(player, MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_SEARCHER)
          htmltext = "30511-09.htm" # fnLowLevel11
        else
          htmltext = "30511-10.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(player, MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_SEARCHER)
        take_items(player, -1, {MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_SEARCHER})
        player.class_id = BOUNTY_HUNTER
        player.base_class = BOUNTY_HUNTER
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30511-11.htm" # fnAfterClassChange11
      else
        htmltext = "30511-12.htm" # fnNoProof11
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    if player.in_category?(CategoryType::FOURTH_CLASS_GROUP) && player.in_category?(CategoryType::BOUNTY_HUNTER_GROUP)
      htmltext = "30511-01.htm" # fnYouAreFourthClass
    elsif player.in_category?(CategoryType::BOUNTY_HUNTER_GROUP)
      class_id = player.class_id
      if class_id.scavenger? || class_id.bounty_hunter?
        htmltext = "30511-02.htm" # fnClassList1
      else
        htmltext = "30511-06.htm" # fnYouAreFirstClass
      end
    else
      htmltext = "30511-07.htm" # fnClassMismatch
    end

    htmltext
  end
end
