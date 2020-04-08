class Scripts::DwarfWarehouseChange1 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30498, # Moke
    30503, # Rikadio
    30594, # Ranspo
    32092  # Alder
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE = 8869
  private RING_OF_RAVEN = 1642
  # Class
  private SCAVENGER = 54

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, player)
    return unless npc && player

    case event
    when "30498-01.htm", # warehouse_chief_moke003
         "30498-02.htm", # warehouse_chief_moke006f
         "30498-03.htm", # warehouse_chief_moke007f
         "30498-04.htm", # warehouse_chief_moke006f
         "30503-01.htm", # warehouse_chief_rikadio003
         "30503-02.htm", # warehouse_chief_rikadio006f
         "30503-03.htm", # warehouse_chief_rikadio007f
         "30503-04.htm", # warehouse_chief_rikadio006f
         "30594-01.htm", # warehouse_chief_ranspo003
         "30594-02.htm", # warehouse_chief_ranspo006f
         "30594-03.htm", # warehouse_chief_ranspo007f
         "30594-04.htm", # warehouse_chief_ranspo006f
         "32092-01.htm", # warehouse_chief_older003
         "32092-02.htm", # warehouse_chief_older006f
         "32092-03.htm", # warehouse_chief_older007f
         "32092-04.htm"  # warehouse_chief_older006f
      event
    when "54"
      class_change_requested(player, npc, event.to_i)
    else
      # automatically added
    end

  end

  private def class_change_requested(player, npc, class_id)
    if player.in_category?(CategoryType::SECOND_CLASS_GROUP)
      "#{npc.id}-06.htm" # fnYouAreSecondClass
    elsif player.in_category?(CategoryType::THIRD_CLASS_GROUP)
      "#{npc.id}-07.htm" # fnYouAreThirdClass
    elsif player.in_category?(CategoryType::FOURTH_CLASS_GROUP)
      "30498-12.htm" # fnYouAreFourthClass
    elsif class_id == SCAVENGER && player.class_id.dwarven_fighter?
      if player.level < 20
        if has_quest_items?(player, RING_OF_RAVEN)
          "#{npc.id}-08.htm" # fnLowLevel11
        else
          "#{npc.id}-09.htm" # fnLowLevelNoProof11
        end
      elsif has_quest_items?(player, RING_OF_RAVEN)
        take_items(player, RING_OF_RAVEN, -1)
        player.class_id = SCAVENGER
        player.base_class = SCAVENGER
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
        "#{npc.id}-10.htm" # fnAfterClassChange11
      else
        "#{npc.id}-11.htm" # fnNoProof11
      end
    end
  end

  def on_talk(npc, player)
    if player.in_category?(CategoryType::BOUNTY_HUNTER_GROUP)
      "#{npc.id}-01.htm" # fnClassList1
    else
      "#{npc.id}-05.htm" # fnClassMismatch
    end
  end
end