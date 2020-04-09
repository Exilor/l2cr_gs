class Scripts::Q00628_HuntGoldenRam < Quest
  # NPCs
  private KAHMAN = 31554
  # Items
  private GOLDEN_RAM_BADGE_RECRUIT = 7246
  private GOLDEN_RAM_BADGE_SOLDIER = 7247
  private SPLINTER_STAKATO_CHITIN = 7248
  private NEEDLE_STAKATO_CHITIN = 7249
  # Misc
  private REQUIRED_ITEM_COUNT = 100
  private MIN_LVL = 66
  # Mobs
  private MOBS_DROP_CHANCES = {
    21508 => ItemChanceHolder.new(SPLINTER_STAKATO_CHITIN, 0.500, 1), # splinter_stakato
    21509 => ItemChanceHolder.new(SPLINTER_STAKATO_CHITIN, 0.430, 1), # splinter_stakato_worker
    21510 => ItemChanceHolder.new(SPLINTER_STAKATO_CHITIN, 0.521, 1), # splinter_stakato_soldier
    21511 => ItemChanceHolder.new(SPLINTER_STAKATO_CHITIN, 0.575, 1), # splinter_stakato_drone
    21512 => ItemChanceHolder.new(SPLINTER_STAKATO_CHITIN, 0.746, 1), # splinter_stakato_drone_a
    21513 => ItemChanceHolder.new(NEEDLE_STAKATO_CHITIN,   0.500, 2), # needle_stakato
    21514 => ItemChanceHolder.new(NEEDLE_STAKATO_CHITIN,   0.430, 2), # needle_stakato_worker
    21515 => ItemChanceHolder.new(NEEDLE_STAKATO_CHITIN,   0.520, 2), # needle_stakato_soldier
    21516 => ItemChanceHolder.new(NEEDLE_STAKATO_CHITIN,   0.531, 2), # needle_stakato_drone
    21517 => ItemChanceHolder.new(NEEDLE_STAKATO_CHITIN,   0.744, 2)  # needle_stakato_drone_a
  }

  def initialize
    super(628, self.class.simple_name, "Hunt of the Golden Ram Mercenary Force")

    add_start_npc(KAHMAN)
    add_talk_id(KAHMAN)
    add_kill_id(MOBS_DROP_CHANCES.keys)
    register_quest_items(SPLINTER_STAKATO_CHITIN, NEEDLE_STAKATO_CHITIN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    qs = get_quest_state(pc, false)
    html = nil
    if qs.nil?
      return html
    end

    case event
    when "accept"
      if qs.created? && pc.level >= MIN_LVL
        qs.start_quest
        if has_quest_items?(pc, GOLDEN_RAM_BADGE_SOLDIER)
          qs.set_cond(3)
          html = "31554-05.htm"
        elsif has_quest_items?(pc, GOLDEN_RAM_BADGE_RECRUIT)
          qs.set_cond(2)
          html = "31554-04.htm"
        else
          html = "31554-03.htm"
        end
      end
    when "31554-08.html"
      if get_quest_items_count(pc, SPLINTER_STAKATO_CHITIN) >= REQUIRED_ITEM_COUNT
        give_items(pc, GOLDEN_RAM_BADGE_RECRUIT, 1)
        take_items(pc, SPLINTER_STAKATO_CHITIN, -1)
        qs.set_cond(2, true)
        html = event
      end
    when "31554-12.html", "31554-13.html"
      if qs.started?
        html = event
      end
    when "31554-14.html"
      if qs.started?
        qs.exit_quest(true, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, -1, 1, npc)
    if qs
      item = MOBS_DROP_CHANCES[npc.id]
      if item.count <= qs.cond && !qs.cond?(3)
        give_item_randomly(qs.player, npc, item.id, 1, REQUIRED_ITEM_COUNT, item.chance, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    unless qs = get_quest_state!(pc)
      return get_no_quest_msg(pc)
    end

    case qs.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "31554-01.htm" : "31554-02.htm"
    when State::STARTED
      splinters = get_quest_items_count(pc, SPLINTER_STAKATO_CHITIN)
      needles = get_quest_items_count(pc, NEEDLE_STAKATO_CHITIN)
      case qs.cond
      when 1
        html = splinters >= REQUIRED_ITEM_COUNT ? "31554-07.html" : "31554-06.html"
      when 2
        if has_quest_items?(pc, GOLDEN_RAM_BADGE_RECRUIT)
          if splinters >= REQUIRED_ITEM_COUNT && needles >= REQUIRED_ITEM_COUNT
            take_items(pc, GOLDEN_RAM_BADGE_RECRUIT, -1)
            take_items(pc, SPLINTER_STAKATO_CHITIN, -1)
            take_items(pc, NEEDLE_STAKATO_CHITIN, -1)
            give_items(pc, GOLDEN_RAM_BADGE_SOLDIER, 1)
            qs.set_cond(3, true)
            html = "31554-10.html"
          else
            html = "31554-09.html"
          end
        else
          qs.set_cond(1)
          if splinters >= REQUIRED_ITEM_COUNT
            html = "31554-07.html"
          else
            html = "31554-06.html"
          end
        end
      when 3
        if has_quest_items?(pc, GOLDEN_RAM_BADGE_SOLDIER)
          html = "31554-11.html"
        else
          qs.set_cond(1)
          if splinters >= REQUIRED_ITEM_COUNT
            html = "31554-07.html"
          else
            html = "31554-06.html"
          end
        end
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
