class Scripts::Q00371_ShrieksOfGhosts < Quest
  private record DropInfo, first_chance : Int32, second_chance : Int32

  # NPCs
  private REVA = 30867
  private PATRIN = 30929
  # Items
  private ANCIENT_ASH_URN = 5903
  private ANCIENT_PORCELAIN = 6002
  private ANCIENT_PORCELAIN_EXCELLENT = 6003
  private ANCIENT_PORCELAIN_HIGH_QUALITY = 6004
  private ANCIENT_PORCELAIN_LOW_QUALITY = 6005
  private ANCIENT_PORCELAIN_LOWEST_QUALITY = 6006
  # Misc
  private MIN_LEVEL = 59

  private MOBS = {
    20818 => DropInfo.new(350, 400), # hallates_warrior
    20820 => DropInfo.new(583, 673), # hallates_knight
    20824 => DropInfo.new(458, 538)  # hallates_commander
  }

  def initialize
    super(371, self.class.simple_name, "Shrieks of Ghosts")

    add_start_npc(REVA)
    add_talk_id(REVA, PATRIN)
    add_kill_id(MOBS.keys)
    register_quest_items(ANCIENT_ASH_URN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30867-02.htm"
      qs.start_quest
      html = event
    when "30867-05.html"
      urn_count = get_quest_items_count(pc, ANCIENT_ASH_URN)

      if urn_count < 1
        html = event
      elsif urn_count < 100
        give_adena(pc, (urn_count * 1000) + 15000, true)
        take_items(pc, ANCIENT_ASH_URN, -1)
        html = "30867-06.html"
      else
        give_adena(pc, (urn_count * 1000) + 37700, true)
        take_items(pc, ANCIENT_ASH_URN, -1)
        html = "30867-07.html"
      end
    when "30867-08.html", "30929-01.html", "30929-02.html"
      html = event
    when "30867-09.html"
      give_adena(pc, get_quest_items_count(pc, ANCIENT_ASH_URN) * 1000, true)
      qs.exit_quest(true, true)
      html = "30867-09.html"
    when "30929-03.html"
      if !has_quest_items?(pc, ANCIENT_PORCELAIN)
        html = event
      else
        random = Rnd.rand(100)

        if random < 2
          give_items(pc, ANCIENT_PORCELAIN_EXCELLENT, 1)
          html = "30929-04.html"

        elsif random < 32
          give_items(pc, ANCIENT_PORCELAIN_HIGH_QUALITY, 1)
          html = "30929-05.html"
        elsif random < 62
          give_items(pc, ANCIENT_PORCELAIN_LOW_QUALITY, 1)
          html = "30929-06.html"
        elsif random < 77
          give_items(pc, ANCIENT_PORCELAIN_LOWEST_QUALITY, 1)
          html = "30929-07.html"
        else
          html = "30929-08.html"
        end

        take_items(pc, ANCIENT_PORCELAIN, 1)
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs.nil? || !Util.in_range?(1500, npc, killer, true)
      return
    end

    info = MOBS[npc.id]
    random = Rnd.rand(1000)

    if random < info.first_chance
      qs.give_item_randomly(npc, ANCIENT_ASH_URN, 1, 0, 1.0, true)
    elsif random < info.second_chance
      qs.give_item_randomly(npc, ANCIENT_PORCELAIN, 1, 0, 1.0, true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "30867-01.htm" : "30867-03.htm"
    elsif qs.started?
      if npc.id == REVA
        if has_quest_items?(pc, ANCIENT_PORCELAIN)
          html = "30867-04.html"
        else
          html = "30867-10.html"
        end
      else
        html = "30929-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
