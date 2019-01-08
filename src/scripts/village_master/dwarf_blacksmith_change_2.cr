class NpcAI::DwarfBlacksmithChange2 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30512, # Kusto
    30677, # Flutter
    30687, # Vergara
    30847, # Ferris
    30897, # Roman
    31272, # Noel
    31317, # Lombert
    31961  # Newyear
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  private MARK_OF_MAESTRO = 2867 # proof11z
  private MARK_OF_GUILDSMAN = 3119 # proof11x
  private MARK_OF_PROSPERITY = 3238 # proof11y
  # Class
  private WARSMITH = 57

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when "30512-03.htm", "30512-04.htm", "30512-05.htm"
      htmltext = event
    when "57"
      htmltext = class_change_requested(pc, event.to_i)
    end

    htmltext
  end

  private def class_change_requested(pc, class_id)
    if pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      htmltext = "30512-08.htm" # fnYouAreThirdClass
    elsif class_id == WARSMITH && pc.class_id.artisan?
      if pc.level < 40
        if has_quest_items?(pc, MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_MAESTRO)
          htmltext = "30512-09.htm" # fnLowLevel11
        else
          htmltext = "30512-10.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(pc, MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_MAESTRO)
        take_items(pc, -1, {MARK_OF_GUILDSMAN, MARK_OF_PROSPERITY, MARK_OF_MAESTRO})
        pc.class_id = WARSMITH
        pc.base_class = WARSMITH
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        htmltext = "30512-11.htm" # fnAfterClassChange11
      else
        htmltext = "30512-12.htm" # fnNoProof11
      end
    end

    htmltext
  end

  def on_talk(npc, pc)
    htmltext = nil
    if pc.in_category?(CategoryType::FOURTH_CLASS_GROUP)
      htmltext = "30512-01.htm" # fnYouAreFourthClass
    elsif pc.in_category?(CategoryType::WARSMITH_GROUP)
      class_id = pc.class_id
      if class_id.artisan? || class_id.warsmith?
        htmltext = "30512-02.htm" # fnClassList1
      else
        htmltext = "30512-06.htm" # fnYouAreFirstClass
      end
    else
      htmltext = "30512-07.htm" # fnClassMismatch
    end

    htmltext
  end
end
