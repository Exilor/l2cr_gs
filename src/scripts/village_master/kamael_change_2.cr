class NpcAI::KamaelChange2 < AbstractNpcAI
  # NPCs
  private NPCS_MALE = {
    32146, # Valpor
    32205, # Aetonic
    32209, # Ferdinand
    32213, # Vitus
    32217, # Barta
    32221, # Brome
    32225, # Taine
    32229, # Hagel
    32233  # Zoldart
  }
  private NPCS_FEMALE = {
    32145, # Maynard
    32206, # Pieche
    32210, # Eddy
    32214, # Meldina
    32218, # Miya
    32222, # Liane
    32226, # Raula
    32230, # Ceci
    32234  # Nizer
  }

  # Items
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  private ORKURUS_RECOMMENDATION = 9760
  private KAMAEL_INQUISITOR_MARK = 9782
  private SOUL_BREAKER_CERTIFICATE = 9806

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS_MALE)
    add_start_npc(NPCS_FEMALE)
    add_talk_id(NPCS_MALE)
    add_talk_id(NPCS_FEMALE)
  end

  def on_adv_event(event, npc, player)
    return unless npc && player

    case event
    when "32145-05.htm", # master_all_kamael003
         "32145-06.htm", # master_all_kamael006t
         "32145-07.htm", # master_all_kamael007t
         "32145-08.htm", # master_all_kamael006ms
         "32145-09.htm", # master_all_kamael007ms
         "32145-11.htm", # master_all_kamael003
         "32145-12.htm", # master_all_kamael006w
         "32145-13.htm", # master_all_kamael007w
         "32145-14.htm", # master_all_kamael006fs
         "32145-15.htm"  # master_all_kamael007fs
      htmltext = event
    when "127", "128", "129", "130"
      htmltext = class_change_requested(player, npc, event.to_i)
    end

    htmltext
  end

  private def class_change_requested(player, npc, class_id)
    htmltext = nil
    if CategoryData.in_category?(CategoryType::KAMAEL_THIRD_CLASS_GROUP, class_id)
      if player.in_category?(CategoryType::KAMAEL_FIRST_CLASS_GROUP)
        if NPCS_MALE.includes?(npc.id)
          htmltext = "32145-02.htm" # master_all_kamael012b
        else
          htmltext = "32145-03.htm" # master_all_kamael012c
        end
      elsif player.in_category?(CategoryType::KAMAEL_THIRD_CLASS_GROUP)
        if NPCS_MALE.includes?(npc.id)
          htmltext = "32145-16.htm" # master_all_kamael005b
        else
          htmltext = "32145-17.htm" # master_all_kamael005c
        end
      elsif player.in_category?(CategoryType::KAMAEL_FOURTH_CLASS_GROUP)
        if NPCS_MALE.includes?(npc.id)
          htmltext = "32145-18.htm" # master_all_kamael100b
        else
          htmltext = "32145-19.htm" # master_all_kamael100c
        end
      elsif player.class_id.trooper?
        if NPCS_MALE.includes?(npc.id)
          if class_id == 127
            qs = player.get_quest_state("Q00064_CertifiedBerserker")
            if player.level < 40
              if qs && qs.completed?
                htmltext = "32145-20.htm" # master_all_kamael008ta
              else
                htmltext = "32145-21.htm" # master_all_kamael009ta
              end
            elsif (qs.nil?) || !qs.completed?
              htmltext = "32145-22.htm" # master_all_kamael010ta
            else
              take_items(player, ORKURUS_RECOMMENDATION, -1)
              player.class_id = 127
              player.base_class = 127
              # SystemMessage and cast skill is done by class_id=
              player.broadcast_user_info
              give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
              htmltext = "32145-23.htm" # master_all_kamael011ta
            end
          elsif class_id == 128
            qs = player.get_quest_state("Q00065_CertifiedSoulBreaker")
            if player.level < 40
              if qs && qs.completed?
                htmltext = "32145-24.htm" # master_all_kamael008msa
              else
                htmltext = "32145-25.htm" # master_all_kamael009msa
              end
            elsif (qs.nil?) || !qs.completed?
              htmltext = "32145-26.htm" # master_all_kamael010msa
            else
              take_items(player, SOUL_BREAKER_CERTIFICATE, -1)
              player.class_id = 128
              player.base_class = 128
              # SystemMessage and cast skill is done by class_id=
              player.broadcast_user_info
              give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
              htmltext = "32145-27.htm" # master_all_kamael011msa
            end
          end
        else
          htmltext = "32145-10.htm" # master_all_kamael002c
        end
      elsif player.class_id.warder?
        if NPCS_MALE.includes?(npc.id)
          htmltext = "32145-04.htm" # master_all_kamael002b
        else
          if class_id == 129
            qs = player.get_quest_state("Q00065_CertifiedSoulBreaker")
            if player.level < 40
              if qs && qs.completed?
                htmltext = "32145-28.htm" # master_all_kamael008fsa
              else
                htmltext = "32145-29.htm" # master_all_kamael009fsa
              end
            elsif (qs.nil?) || !qs.completed?
              htmltext = "32145-30.htm" # master_all_kamael010fsa
            else
              take_items(player, SOUL_BREAKER_CERTIFICATE, -1)
              player.class_id = 129
              player.base_class = 129
              # SystemMessage and cast skill is done by class_id=
              player.broadcast_user_info
              give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
              htmltext = "32145-31.htm" # master_all_kamael011fsa
            end
          elsif class_id == 130
            qs = player.get_quest_state("Q00066_CertifiedArbalester")
            if player.level < 40
              if qs && qs.completed?
                htmltext = "32145-32.htm" # master_all_kamael008wa
              else
                htmltext = "32145-33.htm" # master_all_kamael009wa
              end
            elsif (qs.nil?) || !qs.completed?
              htmltext = "32145-34.htm" # master_all_kamael010wa
            else
              take_items(player, KAMAEL_INQUISITOR_MARK, -1)
              player.class_id = 130
              player.base_class = 130
              # SystemMessage and cast skill is done by class_id=
              player.broadcast_user_info
              give_items(player, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
              htmltext = "32145-35.htm" # master_all_kamael011wa
            end
          end
        end
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    if !player.race.kamael?
      htmltext = "32145-01.htm" # master_all_kamael002a
    elsif player.in_category?(CategoryType::KAMAEL_FIRST_CLASS_GROUP)
      if player.class_id.male_soldier?
        htmltext = "32145-02.htm" # master_all_kamael012b
      elsif player.class_id.female_soldier?
        htmltext = "32145-03.htm" # master_all_kamael012c
      end
    elsif player.in_category?(CategoryType::KAMAEL_SECOND_CLASS_GROUP)
      if NPCS_MALE.includes?(npc.id)
        if player.in_category?(CategoryType::KAMAEL_FEMALE_MAIN_OCCUPATION)
          htmltext = "32145-04.htm" # master_all_kamael002b
          return htmltext
        end

        if player.class_id.trooper?
          htmltext = "32145-05.htm" # master_all_kamael003t
        elsif player.class_id.warder?
          htmltext = "32145-02.htm" # master_all_kamael012b
        end
      else
        if player.in_category?(CategoryType::KAMAEL_MALE_MAIN_OCCUPATION)
          htmltext = "32145-10.htm" # master_all_kamael002c
          return htmltext
        end

        if player.class_id.trooper?
          htmltext = "32145-03.htm" # master_all_kamael012c
        elsif player.class_id.warder?
          htmltext = "32145-11.htm" # master_all_kamael003w
        end
      end
    elsif player.in_category?(CategoryType::KAMAEL_THIRD_CLASS_GROUP)
      if NPCS_MALE.includes?(npc.id)
        if player.in_category?(CategoryType::KAMAEL_MALE_MAIN_OCCUPATION)
          htmltext = "32145-16.htm" # master_all_kamael005b
        else
          htmltext = "32145-04.htm" # master_all_kamael002b
        end
      else
        if player.in_category?(CategoryType::KAMAEL_FEMALE_MAIN_OCCUPATION)
          htmltext = "32145-17.htm" # master_all_kamael005c
        else
          htmltext = "32145-10.htm" # master_all_kamael002c
        end
      end
    elsif player.in_category?(CategoryType::KAMAEL_FOURTH_CLASS_GROUP)
      if NPCS_MALE.includes?(npc.id)
        if player.in_category?(CategoryType::KAMAEL_MALE_MAIN_OCCUPATION)
          htmltext = "32145-18.htm" # master_all_kamael100b
        else
          htmltext = "32145-04.htm" # master_all_kamael002b
        end
      else
        if player.in_category?(CategoryType::KAMAEL_FEMALE_MAIN_OCCUPATION)
          htmltext = "32145-19.htm" # master_all_kamael100c
        else
          htmltext = "32145-10.htm" # master_all_kamael002c
        end
      end
    end

    htmltext
  end
end
