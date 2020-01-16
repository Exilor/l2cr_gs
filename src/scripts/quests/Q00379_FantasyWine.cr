class Scripts::Q00379_FantasyWine < Quest
  # NPC
  private HARLAN = 30074
  # Items
  private LEAF_OF_EUCALYPTUS = ItemHolder.new(5893, 80)
  private STONE_OF_CHILL = ItemHolder.new(5894, 100)
  private OLD_WINE_15_YEAR = 5956
  private OLD_WINE_30_YEAR = 5957
  private OLD_WINE_60_YEAR = 5958
  # Monsters
  private ENKU_ORC_CHAMPION = 20291
  private ENKU_ORC_SHAMAN = 20292
  # Misc
  private MIN_LEVEL = 20

  def initialize
    super(379, self.class.simple_name, "Fantasy Wine")

    add_start_npc(HARLAN)
    add_talk_id(HARLAN)
    add_kill_id(ENKU_ORC_CHAMPION, ENKU_ORC_SHAMAN)
    register_quest_items(LEAF_OF_EUCALYPTUS.id, STONE_OF_CHILL.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30074-02.htm", "30074-03.htm", "30074-05.html"
      html = event
    when "30074-04.htm"
      qs.start_quest
      html = event
    when "30074-11.html"
      if has_all_items?(pc, true, LEAF_OF_EUCALYPTUS, STONE_OF_CHILL)
        random = Rnd.rand(10)

        if random < 3
          item = OLD_WINE_15_YEAR
          html = event
        elsif random < 9
          item = OLD_WINE_30_YEAR
          html = "30074-12.html"
        else
          item = OLD_WINE_60_YEAR
          html = "30074-13.html"
        end

        give_items(pc, item, 1)
        take_all_items(pc, LEAF_OF_EUCALYPTUS, STONE_OF_CHILL)
        qs.exit_quest(true, true)
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs.nil? || !Util.in_range?(1500, npc, killer, true)
      return
    end

    drop_item = npc.id == ENKU_ORC_CHAMPION ? LEAF_OF_EUCALYPTUS : STONE_OF_CHILL

    if give_item_randomly(killer, npc, drop_item.id, 1, drop_item.count, 1.0, true)
      if has_all_items?(killer, true, LEAF_OF_EUCALYPTUS, STONE_OF_CHILL)
        qs.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "30074-01.htm" : "30074-06.html"
    elsif qs.started?
      has_leaf = has_item?(pc, LEAF_OF_EUCALYPTUS)
      has_stone = has_item?(pc, STONE_OF_CHILL)

      if !has_leaf && !has_stone
        html = "30074-07.html"
      elsif has_leaf && !has_stone
        html = "30074-08.html"
      elsif !has_leaf && has_stone
        html = "30074-09.html"
      else
        html = "30074-10.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
