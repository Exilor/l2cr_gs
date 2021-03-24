class Scripts::Q00352_HelpRoodRaiseANewPet < Quest
  private record DropInfo, first_chance : Int32, second_chance : Int32

  # NPC
  private ROOD = 31067
  # Items
  private LIENRIK_EGG1 = 5860
  private LIENRIK_EGG2 = 5861
  # Misc
  private MIN_LEVEL = 39

  private MOBS = {
    20786 => DropInfo.new(46, 48), # lienrik
    21644 => DropInfo.new(46, 48), # lienrik_a
    21645 => DropInfo.new(69, 71)  # lienrik_lad_a
  }

  def initialize
    super(352, self.class.simple_name, "Help Rood Raise A New Pet!")

    add_start_npc(ROOD)
    add_talk_id(ROOD)
    add_kill_id(MOBS.keys)
    register_quest_items(LIENRIK_EGG1, LIENRIK_EGG2)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "31067-02.htm", "31067-03.htm", "31067-07.html", "31067-10.html"
      html = event
    when "31067-04.htm"
      qs.memo_state = 1
      qs.start_quest
      html = event
    when "31067-08.html"
      qs.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs.nil? || !Util.in_range?(1500, npc, killer, true)
      return
    end

    info = MOBS[npc.id]
    random = Rnd.rand(100)

    if random < info.first_chance
      qs.give_item_randomly(npc, LIENRIK_EGG1, 1, 0, 1.0, true)
    elsif random < info.second_chance
      qs.give_item_randomly(npc, LIENRIK_EGG2, 1, 0, 1.0, true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "31067-01.htm" : "31067-05.html"
    elsif qs.started?
      egg1_count = get_quest_items_count(pc, LIENRIK_EGG1)
      egg2_count = get_quest_items_count(pc, LIENRIK_EGG2)

      if egg1_count == 0 && egg2_count == 0
        html = "31067-06.html"
      elsif egg1_count >= 1 && egg2_count == 0
        if egg1_count >= 10
          give_adena(pc, (egg1_count &* 34) &+ 4000, true)
        else
          give_adena(pc, (egg1_count &* 34) &+ 2000, true)
        end

        take_items(pc, LIENRIK_EGG1, -1)
        html = "31067-10.html"
      elsif egg1_count >= 1
        give_adena(pc, 4000i64 &+ ((egg1_count &* 34) &+ (egg2_count &* 1025)), true)
        take_items(pc, LIENRIK_EGG1, -1)
        take_items(pc, LIENRIK_EGG2, -1)
        html = "31067-11.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
