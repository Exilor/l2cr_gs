class Scripts::Q00252_ItSmellsDelicious < Quest
  # NPC
  private STAN = 30200
  # Items
  private DIARY = 15500
  private COOKBOOK_PAGE = 15501
  # Monsters
  private MOBS = {
    22786,
    22787,
    22788
  }
  private CHEF = 18908
  # Misc
  private DIARY_CHANCE = 0.599
  private DIARY_MAX_COUNT = 10
  private COOKBOOK_PAGE_CHANCE = 0.36
  private COOKBOOK_PAGE_MAX_COUNT = 5

  def initialize
    super(252, self.class.simple_name, "It Smells Delicious!")

    add_start_npc(STAN)
    add_talk_id(STAN)
    add_kill_id(CHEF)
    add_kill_id(MOBS)
    register_quest_items(DIARY, COOKBOOK_PAGE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30200-04.htm"
      html = event
    when "30200-05.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30200-08.html"
      if qs.cond?(2)
        give_adena(pc, 147656, true)
        add_exp_and_sp(pc, 716238, 78324)
        qs.exit_quest(false, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == CHEF # only the killer gets quest items from the chef
      qs = get_quest_state(killer, false)
      if qs && qs.cond?(1)
        if give_item_randomly(killer, npc, COOKBOOK_PAGE, 1, COOKBOOK_PAGE_MAX_COUNT, COOKBOOK_PAGE_CHANCE, true)
          if has_max_diaries?(qs)
            qs.set_cond(2, true)
          end
        end
      end
    else
      if qs = get_random_party_member_state(killer, 1, 3, npc)
        if give_item_randomly(qs.player, npc, DIARY, 1, DIARY_MAX_COUNT, DIARY_CHANCE, true)
          if has_max_cookbook_pages?(qs)
            qs.set_cond(2, true)
          end
        end
      end
    end

    super
  end

  def check_party_member(qs, npc)
    !has_max_diaries?(qs)
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= 82 ? "30200-01.htm" : "30200-02.htm"
    elsif qs.started?
      case qs.cond
      when 1
        html = "30200-06.html"
      when 2
        if has_max_diaries?(qs) && has_max_cookbook_pages?(qs)
          html = "30200-07.html"
        end
      else
        # [automatically added else]
      end

    else
      html = "30200-03.html"
    end

    html || get_no_quest_msg(pc)
  end

  private def has_max_diaries?(qs)
    get_quest_items_count(qs.player, DIARY) >= DIARY_MAX_COUNT
  end

  private def has_max_cookbook_pages?(qs)
    get_quest_items_count(qs.player, COOKBOOK_PAGE) >= COOKBOOK_PAGE_MAX_COUNT
  end
end
