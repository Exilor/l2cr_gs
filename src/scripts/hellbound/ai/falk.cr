class Scripts::Falk < AbstractNpcAI
  # NPCs
  private FALK = 32297
  # Items
  private DARION_BADGE = 9674
  private BASIC_CERT = 9850 # Basic Caravan Certificate
  private STANDART_CERT = 9851 # Standard Caravan Certificate
  private PREMIUM_CERT = 9852 # Premium Caravan Certificate

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_first_talk_id(FALK)
    add_start_npc(FALK)
    add_talk_id(FALK)
  end

  def on_first_talk(npc, pc)
    if has_at_least_one_quest_item?(pc, BASIC_CERT, STANDART_CERT, PREMIUM_CERT)
      return "32297-01a.htm"
    end

    "32297-01.htm"
  end

  def on_talk(npc, pc)
    if has_at_least_one_quest_item?(pc, BASIC_CERT, STANDART_CERT, PREMIUM_CERT)
      return "32297-01a.htm"
    end

    "32297-02.htm"
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if event.casecmp?("badges")
      unless has_at_least_one_quest_item?(pc, BASIC_CERT, STANDART_CERT, PREMIUM_CERT)
        if get_quest_items_count(pc, DARION_BADGE) >= 20
          take_items(pc, DARION_BADGE, 20)
          give_items(pc, BASIC_CERT, 1)
          return "32297-02a.htm"
        end

        return "32297-02b.htm"
      end
    end

    super
  end
end
