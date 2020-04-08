class Scripts::KamaelChange1 < AbstractNpcAI
  # NPCs
  private NPCS = {
    32191, # Hanarin
    32193, # Yeniche
    32196, # Gershwin
    32199, # Holst
    32202  # Khadava
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE = 8869
  private GWAINS_RECOMMENDATION = 9753
  private STEELRAZOR_EVALUATION = 9772

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when "32191-02.htm", # master_all_kamael003
         "32191-03.htm", # master_all_kamael006m
         "32191-04.htm", # master_all_kamael007m
         "32191-05.htm", # master_all_kamael007mai
         "32191-06.htm", # master_all_kamael003
         "32191-07.htm", # master_all_kamael006f
         "32191-08.htm", # master_all_kamael007f
         "32191-09.htm" # master_all_kamael007f
      event
    when "125", "126"
      class_change_requested(pc, event.to_i)
    else
      # automatically added
    end

  end

  private def class_change_requested(pc, class_id)
    if CategoryData.in_category?(CategoryType::KAMAEL_SECOND_CLASS_GROUP, class_id)
      if pc.in_category?(CategoryType::KAMAEL_SECOND_CLASS_GROUP)
        "32191-10.htm" # master_all_kamael004a
      elsif pc.in_category?(CategoryType::KAMAEL_THIRD_CLASS_GROUP)
        "32191-11.htm" # master_all_kamael005a
      elsif pc.in_category?(CategoryType::KAMAEL_FOURTH_CLASS_GROUP)
        "32191-12.htm" # master_all_kamael100a
      elsif class_id == 125 && pc.class_id.male_soldier?
        qs = pc.get_quest_state("Q00062_PathOfTheTrooper")
        if pc.level < 20
          if qs && qs.completed?
            "32191-13.htm" # master_all_kamael009ma
          else
            "32191-14.htm" # master_all_kamael008ma
          end
        elsif qs.nil? || !qs.completed?
          "32191-15.htm" # master_all_kamael010ma
        else
          take_items(pc, GWAINS_RECOMMENDATION, -1)
          pc.class_id = 125
          pc.base_class = 125
          # SystemMessage and cast skill is done by class_id=
          pc.broadcast_user_info
          give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
          "32191-16.htm" # master_all_kamael011ma
        end
      elsif class_id == 126 && pc.class_id.female_soldier?
        qs = pc.get_quest_state("Q00063_PathOfTheWarder")
        if pc.level < 20
          if qs && qs.completed?
            "32191-17.htm" # master_all_kamael008fa
          else
            "32191-18.htm" # master_all_kamael009fa
          end
        elsif qs.nil? || !qs.completed?
          "32191-19.htm" # master_all_kamael010fa
        else
          take_items(pc, STEELRAZOR_EVALUATION, -1)
          pc.class_id = 126
          pc.base_class = 126
          # SystemMessage and cast skill is done by class_id=
          pc.broadcast_user_info
          give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_D_GRADE, 15)
          "32191-20.htm" # master_all_kamael011fa
        end
      end
    end
  end

  def on_talk(npc, pc)
    if !pc.race.kamael?
      "32191-01.htm" # master_all_kamael002a
    elsif pc.in_category?(CategoryType::KAMAEL_FIRST_CLASS_GROUP)
      if pc.class_id.male_soldier?
        "32191-02.htm" # master_all_kamael003m
      elsif pc.class_id.female_soldier?
        "32191-06.htm" # master_all_kamael003f
      end
    elsif pc.in_category?(CategoryType::KAMAEL_SECOND_CLASS_GROUP)
      "32191-10.htm" # master_all_kamael004a
    elsif pc.in_category?(CategoryType::KAMAEL_THIRD_CLASS_GROUP)
      "32191-11.htm" # master_all_kamael005a
    else
      "32191-12.htm" # master_all_kamael100a
    end
  end
end