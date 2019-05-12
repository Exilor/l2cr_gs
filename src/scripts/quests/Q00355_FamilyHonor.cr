class Scripts::Q00355_FamilyHonor < Quest
  private record DropInfo, first_chance : Int32, second_chance : Int32

  # NPCs
  private GALIBREDO = 30181
  private PATRIN = 30929
  # Items
  private GALFREDO_ROMERS_BUST = 4252
  private SCULPTOR_BERONA = 4350
  private ANCIENT_STATUE_PROTOTYPE = 4351
  private ANCIENT_STATUE_ORIGINAL = 4352
  private ANCIENT_STATUE_REPLICA = 4353
  private ANCIENT_STATUE_FORGERY = 4354
  # Misc
  private MIN_LEVEL = 36

  private MOBS = {
    20767 => DropInfo.new(560, 684), # timak_orc_troop_leader
    20768 => DropInfo.new(530, 650), # timak_orc_troop_shaman
    20769 => DropInfo.new(420, 516), # timak_orc_troop_warrior
    20770 => DropInfo.new(440, 560)  # timak_orc_troop_archer
  }

  def initialize
    super(355, self.class.simple_name, "Family Honor")

    add_start_npc(GALIBREDO)
    add_talk_id(GALIBREDO, PATRIN)
    add_kill_id(MOBS.keys)
    register_quest_items(GALFREDO_ROMERS_BUST)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30181-02.htm", "30181-09.html", "30929-01.html", "30929-02.html"
      html = event
    when "30181-03.htm"
      qs.start_quest
      html = event
    when "30181-06.html"
      bust_count = get_quest_items_count(pc, GALFREDO_ROMERS_BUST)

      if bust_count < 1
        html = event
      elsif bust_count >= 100
        give_adena(pc, (bust_count * 120) + 7800, true)
        take_items(pc, GALFREDO_ROMERS_BUST, -1)
        html = "30181-07.html"
      else
        give_adena(pc, (bust_count * 120) + 2800, true)
        take_items(pc, GALFREDO_ROMERS_BUST, -1)
        html = "30181-08.html"
      end
    when "30181-10.html"
      bust_count = get_quest_items_count(pc, GALFREDO_ROMERS_BUST)

      if bust_count > 0
        give_adena(pc, bust_count * 120, true)
      end

      take_items(pc, GALFREDO_ROMERS_BUST, -1)
      qs.exit_quest(true, true)
      html = event
    when "30929-03.html"
      random = rand(100)

      if has_quest_items?(pc, SCULPTOR_BERONA)
        if random < 2
          give_items(pc, ANCIENT_STATUE_PROTOTYPE, 1)
          html = event
        elsif random < 32
          give_items(pc, ANCIENT_STATUE_ORIGINAL, 1)
          html = "30929-04.html"
        elsif random < 62
          give_items(pc, ANCIENT_STATUE_REPLICA, 1)
          html = "30929-05.html"
        elsif random < 77
          give_items(pc, ANCIENT_STATUE_FORGERY, 1)
          html = "30929-06.html"
        else
          html = "30929-07.html"
        end

        take_items(pc, SCULPTOR_BERONA, 1)
      else
        html = "30929-08.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs.nil? || !Util.in_range?(1500, npc, killer, true)
      return
    end

    info = MOBS[npc.id]
    random = rand(1000)

    if random < info.first_chance
      qs.give_item_randomly(npc, GALFREDO_ROMERS_BUST, 1, 0, 1.0, true)
    elsif random < info.second_chance
      qs.give_item_randomly(npc, SCULPTOR_BERONA, 1, 0, 1.0, true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "30181-01.htm" : "30181-04.html"
    elsif qs.started?
      if npc.id == GALIBREDO
        if has_quest_items?(pc, SCULPTOR_BERONA)
          html = "30181-11.html"
        else
          html = "30181-05.html"
        end
      else
        html = "30929-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
