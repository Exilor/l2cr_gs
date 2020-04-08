class Scripts::Hude < AbstractNpcAI
  # NPCs
  private HUDE = 32298
  # Items
  private BASIC_CERT = 9850
  private STANDART_CERT = 9851
  private PREMIUM_CERT = 9852
  private MARK_OF_BETRAYAL = 9676
  private LIFE_FORCE = 9681
  private CONTAINED_LIFE_FORCE = 9682
  private MAP = 9994
  private STINGER = 10012

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_first_talk_id(HUDE)
    add_start_npc(HUDE)
    add_talk_id(HUDE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when "scertif"
      if HellboundEngine.level > 3
        if has_quest_items?(pc, BASIC_CERT) && get_quest_items_count(pc, MARK_OF_BETRAYAL) >= 30 && get_quest_items_count(pc, STINGER) >= 60
          take_items(pc, MARK_OF_BETRAYAL, 30)
          take_items(pc, STINGER, 60)
          take_items(pc, BASIC_CERT, 1)
          give_items(pc, STANDART_CERT, 1)
          return "32298-04a.htm"
        end
      end
      return "32298-04b.htm"
    when "pcertif"
      if HellboundEngine.level > 6
        if has_quest_items?(pc, STANDART_CERT) && get_quest_items_count(pc, LIFE_FORCE) >= 56 && get_quest_items_count(pc, CONTAINED_LIFE_FORCE) >= 14
          take_items(pc, LIFE_FORCE, 56)
          take_items(pc, CONTAINED_LIFE_FORCE, 14)
          take_items(pc, STANDART_CERT, 1)
          give_items(pc, PREMIUM_CERT, 1)
          give_items(pc, MAP, 1)
          return "32298-06a.htm"
        end
      end
      return "32298-06b.htm"
    when "multisell1"
      if has_quest_items?(pc, STANDART_CERT) || has_quest_items?(pc, PREMIUM_CERT)
        MultisellData.separate_and_send(322980001, pc, npc, false)
      end
    when "multisell2"
      if has_quest_items?(pc, PREMIUM_CERT)
        MultisellData.separate_and_send(322980002, pc, npc, false)
      end
    else
      # automatically added
    end


    super
  end

  def on_first_talk(npc, pc)
    if !has_at_least_one_quest_item?(pc, BASIC_CERT, STANDART_CERT, PREMIUM_CERT)
      "32298-01.htm"
    elsif has_quest_items?(pc, BASIC_CERT) && !has_at_least_one_quest_item?(pc, STANDART_CERT, PREMIUM_CERT)
      "32298-03.htm"
    elsif has_quest_items?(pc, STANDART_CERT) && !has_quest_items?(pc, PREMIUM_CERT)
      "32298-05.htm"
    elsif has_quest_items?(pc, PREMIUM_CERT)
      "32298-07.htm"
    end
  end
end