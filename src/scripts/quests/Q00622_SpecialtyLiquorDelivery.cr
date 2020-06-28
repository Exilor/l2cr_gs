class Scripts::Q00622_SpecialtyLiquorDelivery < Quest
  # NPCs
  private JEREMY = 31521
  private PULIN = 31543
  private NAFF = 31544
  private CROCUS = 31545
  private KUBER = 31546
  private BOELIN = 31547
  private LIETTA = 31267
  # Items
  private SPECIAL_DRINK = 7197
  private SPECIAL_DRINK_PRICE = 7198
  # Rewards
  private QUICK_STEP_POTION = 734
  private SEALED_RING_OF_AURAKYRA = 6849
  private SEALED_SANDDRAGONS_EARING = 6847
  private SEALED_DRAGON_NECKLACE = 6851
  # Misc
  private MIN_LVL = 68
  # Talkers
  private TALKERS = {KUBER, CROCUS, NAFF, PULIN}

  def initialize
    super(622, self.class.simple_name, "Specialty Liquor Delivery")

    add_start_npc(JEREMY)
    add_talk_id(JEREMY, BOELIN, LIETTA)
    add_talk_id(TALKERS)
    register_quest_items(SPECIAL_DRINK, SPECIAL_DRINK_PRICE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31521-03.htm"
      if qs.created?
        qs.start_quest
        give_items(pc, SPECIAL_DRINK, 5)
        html = event
      end
    when "31521-06.html"
      if qs.cond?(6)
        if get_quest_items_count(pc, SPECIAL_DRINK_PRICE) >= 5
          qs.set_cond(7, true)
          take_items(pc, -1, SPECIAL_DRINK_PRICE)
          html = event
        else
          html = "31521-07.html"
        end
      end
    when "31547-02.html"
      if qs.cond?(1)
        if has_quest_items?(pc, SPECIAL_DRINK)
          qs.set_cond(2, true)
          take_items(pc, SPECIAL_DRINK, 1)
          give_items(pc, SPECIAL_DRINK_PRICE, 1)
          html = event
        else
          html = "31547-03.html"
        end
      end
    when "31543-02.html", "31544-02.html", "31545-02.html", "31546-02.html"
      npc = npc.not_nil!
      idx = TALKERS.index(npc.id)
      if idx && qs.cond?(idx + 2)
        if has_quest_items?(pc, SPECIAL_DRINK)
          qs.set_cond(qs.cond + 1, true)
          take_items(pc, SPECIAL_DRINK, 1)
          give_items(pc, SPECIAL_DRINK_PRICE, 1)
          html = event
        else
          html = "#{npc.id}-03.html"
        end
      end
    when "31267-02.html"
      if qs.cond?(7)
        rnd = Rnd.rand(1000)
        if rnd < 800
          reward_items(pc, QUICK_STEP_POTION, 1)
          give_adena(pc, 18800, true)
        elsif rnd < 880
          reward_items(pc, SEALED_RING_OF_AURAKYRA, 1)
        elsif rnd < 960
          reward_items(pc, SEALED_SANDDRAGONS_EARING, 1)
        else
          reward_items(pc, SEALED_DRAGON_NECKLACE, 1)
        end
        qs.exit_quest(true, true)
        html = event
      end
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when JEREMY
      case qs.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "31521-01.htm" : "31521-02.htm"
      when State::STARTED
        case qs.cond
        when 1
          html = "31521-04.html"
        when 6
          if has_quest_items?(pc, SPECIAL_DRINK_PRICE)
            html = "31521-05.html"
          end
        when 7
          unless has_quest_items?(pc, SPECIAL_DRINK)
            html = "31521-08.html"
          end
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    when BOELIN
      if qs.started?
        case qs.cond
        when 1
          if get_quest_items_count(pc, SPECIAL_DRINK) >= 5
            html = "31547-01.html"
          end
        when 2
          html = "31547-04.html"
        end

      end
    when KUBER, CROCUS, NAFF, PULIN
      if qs.started?
        idx = TALKERS.index(npc.id).not_nil!
        cond = idx + 2
        if qs.cond?(cond) && has_quest_items?(pc, SPECIAL_DRINK_PRICE) # 2,3,4,5
          html = "#{npc.id}-01.html"
        elsif qs.cond?(cond + 1) # 3,4,5,6
          html = "#{npc.id}-04.html"
        end
      end
    when LIETTA
      if qs.started? && qs.cond?(7)
        html = "31267-01.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
