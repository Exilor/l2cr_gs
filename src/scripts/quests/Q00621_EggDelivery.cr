class Scripts::Q00621_EggDelivery < Quest
  # NPCs
  private JEREMY = 31521
  private PULIN = 31543
  private NAFF = 31544
  private CROCUS = 31545
  private KUBER = 31546
  private BOELIN = 31547
  private VALENTINE = 31584
  # Items
  private BOILED_EGG = 7195
  private EGG_PRICE = 7196
  # Misc
  private MIN_LVL = 68
  # Reward
  private QUICK_STEP_POTION = 734
  private SEALED_RING_OF_AURAKYRA = 6849
  private SEALED_SANDDRAGONS_EARING = 6847
  private SEALED_DRAGON_NECKLACE = 6851
  # Talkers
  private TALKERS = {NAFF, CROCUS, KUBER, BOELIN}

  def initialize
    super(621, self.class.simple_name, "Egg Delivery")

    add_start_npc(JEREMY)
    add_talk_id(JEREMY, PULIN, VALENTINE)
    add_talk_id(TALKERS)
    register_quest_items(BOILED_EGG, EGG_PRICE)
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
        give_items(pc, BOILED_EGG, 5)
        html = event
      end
    when "31521-06.html"
      if qs.cond?(6)
        if get_quest_items_count(pc, EGG_PRICE) >= 5
          qs.set_cond(7, true)
          take_items(pc, EGG_PRICE, -1)
          html = event
        else
          html = "31521-07.html"
        end
      end
    when "31543-02.html"
      if qs.cond?(1)
        if has_quest_items?(pc, BOILED_EGG)
          qs.set_cond(2, true)
          take_items(pc, BOILED_EGG, 1)
          give_items(pc, EGG_PRICE, 1)
          html = event
        else
          html = "31543-03.html"
        end
      end
    when "31544-02.html", "31545-02.html", "31546-02.html", "31547-02.html"
      npc = npc.not_nil!
      idx = TALKERS.index(npc.id)
      if idx && qs.cond?(idx + 2)
        if has_quest_items?(pc, BOILED_EGG)
          qs.set_cond(qs.cond + 1, true)
          take_items(pc, BOILED_EGG, 1)
          give_items(pc, EGG_PRICE, 1)
          html = event
        else
          html = "#{npc.id}-03.html"
        end
      end
    when "31584-02.html"
      if qs.cond?(7)
        rnd = Rnd.rand(1000)
        if rnd < 800
          reward_items(pc, QUICK_STEP_POTION, 1)
          give_adena(pc, 18800, true)
        elsif rnd < 880
          reward_items(pc, SEALED_RING_OF_AURAKYRA, 1)
        elsif rnd < 960
          reward_items(pc, SEALED_SANDDRAGONS_EARING, 1)
        elsif rnd < 1000
          reward_items(pc, SEALED_DRAGON_NECKLACE, 1)
        end
        qs.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker).not_nil!

    case npc.id
    when JEREMY
      case qs.state
      when State::CREATED
        html = talker.level >= MIN_LVL ? "31521-01.htm" : "31521-02.htm"
      when State::STARTED
        case qs.cond
        when 1
          html = "31521-04.html"
        when 6
          if has_quest_items?(talker, EGG_PRICE)
            html = "31521-05.html"
          end
        when 7
          unless has_quest_items?(talker, BOILED_EGG)
            html = "31521-08.html"
          end
        end
      when State::COMPLETED
        html = get_already_completed_msg(talker)
      end
    when PULIN
      if qs.started?
        case qs.cond
        when 1
          if get_quest_items_count(talker, BOILED_EGG) >= 5
            html = "31543-01.html"
          end
        when 2
          html = "31543-04.html"
        end
      end
    when NAFF, CROCUS, KUBER, BOELIN
      if qs.started?
        idx = TALKERS.index(npc.id).not_nil!
        cond = idx + 2
        if qs.cond?(cond) && has_quest_items?(talker, EGG_PRICE) # 2,3,4,5
          html = "#{npc.id}-01.html"
        elsif qs.cond?(cond + 1) # 3,4,5,6
          html = "#{npc.id}-04.html"
        end
      end
    when VALENTINE
      if qs.started? && qs.cond?(7)
        html = "31584-01.html"
      end
    end

    html || get_no_quest_msg(talker)
  end
end
