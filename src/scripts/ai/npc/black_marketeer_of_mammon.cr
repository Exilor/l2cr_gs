class Scripts::BlackMarketeerOfMammon < AbstractNpcAI
  private BLACK_MARKETEER = 31092
  private MIN_LEVEL = 60

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(BLACK_MARKETEER)
    add_talk_id(BLACK_MARKETEER)
  end

  def on_talk(npc, pc)
    exchange_available? ? "31092-01.html" : "31092-02.html"
  end

  def on_adv_event(event, npc, pc)
    html = event

    if event == "exchange"
      pc = pc.not_nil!
      if exchange_available?
        if pc.level >= MIN_LEVEL
          qs = get_quest_state!(pc)
          if !qs.now_available?
            html = "31092-03.html"
          else
            if pc.adena >= 2_000_000
              qs.state = State::STARTED
              take_items(pc, Inventory::ADENA_ID, 2_000_000)
              give_items(pc, Inventory::ANCIENT_ADENA_ID, 500_000)
              html = "31092-04.html"
              qs.exit_quest(QuestType::DAILY, false)
            else
              html = "31092-05.html"
            end
          end
        else
          html = "31092-06.html"
        end
      else
        html = "31092-02.html"
      end
    end

    html
  end

  private def exchange_available? : Bool
    current_time = Calendar.new
    min_time = Calendar.new
    min_time.hour = 20
    min_time.minute = 0
    min_time.second = 0
    max_time = Calendar.new
    max_time.hour = 23
    max_time.minute = 59
    max_time.second = 59

    (current_time <=> min_time) >= 0 && (current_time <=> max_time) <= 0
  end
end
