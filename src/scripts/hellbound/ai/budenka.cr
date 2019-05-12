class Scripts::Budenka < AbstractNpcAI
  # NPCs
  private BUDENKA = 32294
  # Items
  private STANDART_CERT = 9851
  private PREMIUM_CERT = 9852

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_start_npc(BUDENKA)
    add_first_talk_id(BUDENKA)
    add_talk_id(BUDENKA)
  end

  def on_adv_event(event, npc, player)
    case event
    # when "Budenka-02.html", "Budenka-03.html", "Budenka-04.html", "Budenka-05.html"
    when /\ABudenka-0(?:[2345])\.html\z/
      event
    end
  end

  def on_first_talk(npc, player)
    if has_quest_items?(player, STANDART_CERT, PREMIUM_CERT)
      "Budenka-07.html"
    elsif has_quest_items?(player, STANDART_CERT)
      "Budenka-06.html"
    else
      "Budenka-01.html"
    end
  end
end
