class NpcAI::OrcChange1 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30500, # Osborn
    30505, # Drikus
    30508, # Castor
    32097  # Finker
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE = 8869
  private MARK_OF_RAIDER = 1592
  private KHAVATARI_TOTEM = 1615
  private MASK_OF_MEDIUM = 1631

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, player)
    return unless npc && player

    case event
    when "30500-01.htm", # high_prefect_osborn003
         "30500-02.htm", # high_prefect_osborn006f
         "30500-03.htm", # high_prefect_osborn007f
         "30500-04.htm", # high_prefect_osborn006f
         "30500-05.htm", # high_prefect_osborn007f
         "30500-06.htm", # high_prefect_osborn003
         "30500-07.htm", # high_prefect_osborn006m
         "30500-08.htm", # high_prefect_osborn007m
         "30505-01.htm", # high_prefect_drikus003
         "30505-02.htm", # high_prefect_drikus006f
         "30505-03.htm", # high_prefect_drikus007f
         "30505-04.htm", # high_prefect_drikus006f
         "30505-05.htm", # high_prefect_drikus007f
         "30505-06.htm", # high_prefect_drikus003
         "30505-07.htm", # high_prefect_drikus006m
         "30505-08.htm", # high_prefect_drikus007m
         "30508-01.htm", # high_prefect_cional003
         "30508-02.htm", # high_prefect_cional006f
         "30508-03.htm", # high_prefect_cional007f
         "30508-04.htm", # high_prefect_cional006f
         "30508-05.htm", # high_prefect_cional007f
         "30508-06.htm", # high_prefect_cional003
         "30508-07.htm", # high_prefect_cional006m
         "30508-08.htm", # high_prefect_cional007m
         "32097-01.htm", # high_prefect_finker003
         "32097-02.htm", # high_prefect_finker006f
         "32097-03.htm", # high_prefect_finker007f
         "32097-04.htm", # high_prefect_finker006f
         "32097-05.htm", # high_prefect_finker007f
         "32097-06.htm", # high_prefect_finker003
         "32097-07.htm", # high_prefect_finker006m
         "32097-08.htm" # high_prefect_finker007m
      htmltext = event
    when "45", "47", "50"
      htmltext = class_change_requested(player, npc, event.to_i)
    end

    htmltext
  end

  private def class_change_requested(player, npc, class_id)
    htmltext = nil
    if player.in_category?(CategoryType::SECOND_CLASS_GROUP)
      htmltext = "#{npc.id}-09.htm" # fnYouAreSecondClass
    elsif player.in_category?(CategoryType::THIRD_CLASS_GROUP)
      htmltext = "#{npc.id}-10.htm" # fnYouAreThirdClass
    elsif player.in_category?(CategoryType::FOURTH_CLASS_GROUP)
      htmltext = "30500-24.htm" # fnYouAreFourthClass
    elsif class_id == 45 && player.class_id.orc_fighter?
      if player.level < 20
        if has_quest_items?(player, MARK_OF_RAIDER)
          htmltext = "#{npc.id}-11.htm" # fnLowLevel11
        else
          htmltext = "#{npc.id}-12.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(player, MARK_OF_RAIDER)
        take_items(player, MARK_OF_RAIDER, -1)
        player.class_id = 45
        player.base_class = 45
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
        htmltext = "#{npc.id}-14.htm" # fnAfterClassChange11
      else
        htmltext = "#{npc.id}-13.htm" # fnNoProof11
      end
    elsif class_id == 47 && player.class_id.orc_fighter?
      if player.level < 20
        if has_quest_items?(player, KHAVATARI_TOTEM)
          htmltext = "#{npc.id}-15.htm" # fnLowLevel12
        else
          htmltext = "#{npc.id}-16.htm" # fnLowLevelNoProof12
        end
      elsif has_quest_items?(player, KHAVATARI_TOTEM)
        take_items(player, KHAVATARI_TOTEM, -1)
        player.class_id = 47
        player.base_class = 47
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
        htmltext = "#{npc.id}-18.htm" # fnAfterClassChange12
      else
        htmltext = "#{npc.id}-17.htm" # fnNoProof12
      end
    elsif class_id == 50 && player.class_id.orc_mage?
      if player.level < 20
        if has_quest_items?(player, MASK_OF_MEDIUM)
          htmltext = "#{npc.id}-19.htm" # fnLowLevel21
        else
          htmltext = "#{npc.id}-20.htm" # fnLowLevelNoProof21
        end
      elsif has_quest_items?(player, MASK_OF_MEDIUM)
        take_items(player, MASK_OF_MEDIUM, -1)
        player.class_id = 50
        player.base_class = 50
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
        htmltext = "#{npc.id}-22.htm" # fnAfterClassChange21
      else
        htmltext = "#{npc.id}-21.htm" # fnNoProof21
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    if player.race.orc?
      if player.in_category?(CategoryType::FIGHTER_GROUP)
        htmltext = "#{npc.id}-01.htm" #fnClassList1
      elsif player.in_category?(CategoryType::MAGE_GROUP)
        htmltext = "#{npc.id}-06.htm" # fnClassList2
      end
    else
      htmltext = "#{npc.id}-23.htm" # fnClassMismatch
    end

    htmltext
  end
end
