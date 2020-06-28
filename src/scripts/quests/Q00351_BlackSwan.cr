class Scripts::Q00351_BlackSwan < Quest
  # NPCs
  private ROMAN = 30897
  private GOSTA = 30916
  private IASON_HEINE = 30969
  # Items
  private ORDER_OF_GOSTA = 4296
  private LIZARD_FANG = 4297
  private BARREL_OF_LEAGUE = 4298
  private BILL_OF_IASON_HEINE = 4407
  # Misc
  private MIN_LEVEL = 32
  # Monsters
  private TASABA_LIZARDMAN1 = 20784
  private TASABA_LIZARDMAN_SHAMAN1 = 20785
  private TASABA_LIZARDMAN2 = 21639
  private TASABA_LIZARDMAN_SHAMAN2 = 21640
  private MONSTER_DROP_CHANCES = {
    TASABA_LIZARDMAN1 => 4,
    TASABA_LIZARDMAN_SHAMAN1 => 3,
    TASABA_LIZARDMAN2 => 4,
    TASABA_LIZARDMAN_SHAMAN2 => 3
  }

  def initialize
    super(351, self.class.simple_name, "Black Swan")

    add_start_npc(GOSTA, ROMAN)
    add_talk_id(GOSTA, IASON_HEINE, ROMAN)
    add_kill_id(
      TASABA_LIZARDMAN1, TASABA_LIZARDMAN_SHAMAN1, TASABA_LIZARDMAN2,
      TASABA_LIZARDMAN_SHAMAN2
    )
    register_quest_items(ORDER_OF_GOSTA, LIZARD_FANG, BARREL_OF_LEAGUE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "30916-02.htm", "30969-03.html"
      html = event
    when "30916-03.htm"
      give_items(pc, ORDER_OF_GOSTA, 1)
      qs.start_quest
      html = event
    when "30969-02.html"
      lizard_fang_count = get_quest_items_count(pc, LIZARD_FANG)

      if lizard_fang_count == 0
        html = event
      else
        adena_bonus = lizard_fang_count >= 10 ? 3880i64 : 0i64
        give_adena(pc, adena_bonus + (20 * lizard_fang_count), true)
        take_items(pc, LIZARD_FANG, -1)
        html = "30969-04.html"
      end
    when "30969-05.html"
      barrel_of_league_count = get_quest_items_count(pc, BARREL_OF_LEAGUE)

      if barrel_of_league_count == 0
        html = event
      else
        give_items(pc, BILL_OF_IASON_HEINE, barrel_of_league_count)
        give_adena(pc, 3880, true)
        take_items(pc, BARREL_OF_LEAGUE, -1)
        qs.set_cond(2)
        html = "30969-06.html"
      end
    when "30969-07.html"
      if has_quest_items?(pc, BARREL_OF_LEAGUE, LIZARD_FANG)
        html = "30969-08.html"
      else
        html = event
      end
    when "30969-09.html"
      html = event
      qs.exit_quest(true, true)
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, -1, 3, npc)

    if qs.nil? || !Util.in_range?(1500, npc, killer, true)
      return
    end

    random = Rnd.rand(20)
    if random < 10
      give_item_randomly(qs.player, npc, LIZARD_FANG, 1, 0, 1.0, true)

      if Rnd.rand(20) == 0
        give_item_randomly(qs.player, npc, BARREL_OF_LEAGUE, 1, 0, 1.0, false)
      end
    elsif random < 15
      give_item_randomly(qs.player, npc, LIZARD_FANG, 2, 0, 1.0, true)

      if Rnd.rand(20) == 0
        give_item_randomly(qs.player, npc, BARREL_OF_LEAGUE, 1, 0, 1.0, false)
      end
    elsif Rnd.rand(100) < MONSTER_DROP_CHANCES[npc.id]
      give_item_randomly(qs.player, npc, BARREL_OF_LEAGUE, 1, 0, 1.0, true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    qs2 = pc.get_quest_state(Q00345_MethodToRaiseTheDead.simple_name)

    case npc.id
    when GOSTA
      if qs.created?
        html = pc.level >= MIN_LEVEL ? "30916-01.htm" : "30916-04.html"
      elsif qs.started?
        html = "30916-05.html"
      end
    when IASON_HEINE
      if qs.started?
        html = "30969-01.html"
      end
    when ROMAN
      if qs.started? || qs2 && qs2.started?
        if has_quest_items?(pc, BILL_OF_IASON_HEINE)
          html = "30897-01.html"
        else
          html = "30897-02.html"
        end
      end
    end


    html || get_no_quest_msg(pc)
  end
end
