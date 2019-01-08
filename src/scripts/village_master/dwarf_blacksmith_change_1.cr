class NpcAI::DwarfBlacksmithChange1 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30499, # Tapoy
    30504, # Mendio
    30595, # Opix
    32093  # Bolin
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE = 8869
  private FINAL_PASS_CERTIFICATE = 1635
  # Class
  private ARTISAN = 56

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, player)
    return unless npc && player

    htmltext = nil
    case event
    when "30499-01.htm", # head_blacksmith_tapoy003
         "30499-02.htm", # head_blacksmith_tapoy006f
         "30499-03.htm", # head_blacksmith_tapoy007f
         "30499-04.htm", # head_blacksmith_tapoy006f
         "30504-01.htm", # head_blacksmith_mendio003
         "30504-02.htm", # head_blacksmith_mendio006f
         "30504-03.htm", # head_blacksmith_mendio007f
         "30504-04.htm", # head_blacksmith_mendio006f
         "30595-01.htm", # head_blacksmith_opix003
         "30595-02.htm", # head_blacksmith_opix006f
         "30595-03.htm", # head_blacksmith_opix007f
         "30595-04.htm", # head_blacksmith_opix006f
         "32093-01.htm", # head_blacksmith_boillin003
         "32093-02.htm", # head_blacksmith_boillin006f
         "32093-03.htm", # head_blacksmith_boillin007f
         "32093-04.htm"  # head_blacksmith_boillin006f
      htmltext = event
    when "56"
      htmltext = class_change_requested(player, npc, event.to_i)
    end

    htmltext
  end

  private def class_change_requested(player, npc, class_id)
    if player.in_category?(CategoryType::SECOND_CLASS_GROUP)
      htmltext = "#{npc.id}-06.htm" # fnYouAreSecondClass
    elsif player.in_category?(CategoryType::THIRD_CLASS_GROUP)
      htmltext = "#{npc.id}-07.htm" # fnYouAreThirdClass
    elsif player.in_category?(CategoryType::FOURTH_CLASS_GROUP)
      htmltext = "30499-12.htm" # fnYouAreFourthClass
    elsif class_id == ARTISAN && player.class_id.dwarven_fighter?
      if player.level < 20
        if has_quest_items?(player, FINAL_PASS_CERTIFICATE)
          htmltext = "#{npc.id}-08.htm" # fnLowLevel11
        else
          htmltext = "#{npc.id}-09.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(player, FINAL_PASS_CERTIFICATE)
        take_items(player, FINAL_PASS_CERTIFICATE, -1)
        player.class_id = ARTISAN
        player.base_class = ARTISAN
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
        htmltext = "#{npc.id}-10.htm" # fnAfterClassChange11
      else
        htmltext = "#{npc.id}-11.htm" # fnNoProof11
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    if player.in_category?(CategoryType::WARSMITH_GROUP)
      htmltext = "#{npc.id}-01.htm" # fnClassList1
    else
      htmltext = "#{npc.id}-05.htm" # fnClassMismatch
    end

    htmltext
  end
end
