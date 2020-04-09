class Scripts::Q00117_TheOceanOfDistantStars < Quest
  # NPCs
  private OBI = 32052
  private ABEY = 32053
  private GHOST_OF_A_RAILROAD_ENGINEER = 32054
  private GHOST_OF_AN_ANCIENT_RAILROAD_ENGINEER = 32055
  private BOX = 32076
  # Items
  private ENGRAVED_HAMMER = 8488
  private BOOK_OF_GREY_STAR = 8495
  # Misc
  private MIN_LEVEL = 39
  # Monsters
  private BANDIT_WARRIOR = 22023
  private BANDIT_INSPECTOR = 22024
  private MONSTER_DROP_CHANCES = {
    BANDIT_WARRIOR => 0.179,
    BANDIT_INSPECTOR => 0.1
  }

  def initialize
    super(117, self.class.simple_name, "The Ocean of Distant Stars")

    add_start_npc(ABEY)
    add_talk_id(
      ABEY, GHOST_OF_A_RAILROAD_ENGINEER, GHOST_OF_AN_ANCIENT_RAILROAD_ENGINEER,
      BOX, OBI
    )
    add_kill_id(BANDIT_WARRIOR, BANDIT_INSPECTOR)
    register_quest_items(ENGRAVED_HAMMER, BOOK_OF_GREY_STAR)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "32053-02.htm"
      qs.memo_state = 1
      qs.start_quest
      html = event
    when "32053-06.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(4, true)
        html = event
      end
    when "32053-09.html"
      if qs.memo_state?(5) && has_quest_items?(pc, ENGRAVED_HAMMER)
        qs.memo_state = 6
        qs.set_cond(6, true)
        html = event
      end
    when "32054-02.html"
      if qs.memo_state?(9)
        html = event
      end
    when "32054-03.html"
      if qs.memo_state?(9)
        give_adena(pc, 17647, true)
        add_exp_and_sp(pc, 107387, 7369)
        qs.exit_quest(false, true)
        html = event
      end
    when "32055-02.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "32055-05.html"
      if qs.memo_state?(8)
        if has_quest_items?(pc, ENGRAVED_HAMMER)
          qs.memo_state = 9
          qs.set_cond(10, true)
          take_items(pc, ENGRAVED_HAMMER, -1)
          html = event
        else
          html = "32055-06.html"
        end
      end
    when "32076-02.html"
      if qs.memo_state?(4)
        qs.memo_state = 5
        qs.set_cond(5, true)
        give_items(pc, ENGRAVED_HAMMER, 1)
        html = event
      end
    when "32052-02.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        html = event
      end
    when "32052-05.html"
      if qs.memo_state?(6)
        qs.memo_state = 7
        qs.set_cond(7, true)
        html = event
      end
    when "32052-07.html"
      if qs.memo_state?(7) && has_quest_items?(pc, BOOK_OF_GREY_STAR)
        qs.memo_state = 8
        qs.set_cond(9, true)
        take_items(pc, BOOK_OF_GREY_STAR, -1)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    unless qs = get_random_party_member_state(killer, 7, 3, npc)
      return
    end

    unless Util.in_range?(1500, npc, killer, true)
      return
    end

    if give_item_randomly(killer, npc, BOOK_OF_GREY_STAR, 1, 1, MONSTER_DROP_CHANCES[npc.id], true)
      qs.set_cond(8)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.completed?
      if npc.id == ABEY
        html = get_already_completed_msg(pc)
      end
    elsif qs.created?
      html = pc.level >= MIN_LEVEL ? "32053-01.htm" : "32053-03.htm"
    elsif qs.started?
      case npc.id
      when ABEY
        case qs.memo_state
        when 1
          html = "32053-04.html"
        when 3
          html = "32053-05.html"
        when 4
          html = "32053-07.html"
        when 5
          if has_quest_items?(pc, ENGRAVED_HAMMER)
            html = "32053-08.html"
          end
        when 6
          html = "32053-10.html"
        else
          # [automatically added else]
        end

      when GHOST_OF_A_RAILROAD_ENGINEER
        if qs.memo_state?(9)
          html = "32054-01.html"
      else
        # [automatically added else]
      end

      when GHOST_OF_AN_ANCIENT_RAILROAD_ENGINEER
        case qs.memo_state
        when 1
          html = "32055-01.html"
        when 2
          html = "32055-03.html"
        when 8
          html = "32055-04.html"
        when 9
          html = "32055-07.html"
        else
          # [automatically added else]
        end

      when BOX
        if qs.memo_state?(4)
          html = "32076-01.html"
        elsif qs.memo_state?(5)
          html = "32076-03.html"
        end
      when OBI
        case qs.memo_state
        when 2
          html = "32052-01.html"
        when 3
          html = "32052-03.html"
        when 6
          html = "32052-04.html"
        when 7
          if has_quest_items?(pc, BOOK_OF_GREY_STAR)
            html = "32052-06.html"
          else
            html = "32052-08.html"
          end
        when 8
          html = "32052-09.html"
        else
          # [automatically added else]
        end

      end
    end

    html || get_no_quest_msg(pc)
  end
end
