class Quests::Q00117_TheOceanOfDistantStars < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    unless qs = get_quest_state(player, false)
      return
    end

    case event
    when "32053-02.htm"
      qs.memo_state = 1
      qs.start_quest
      htmltext = event
    when "32053-06.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(4, true)
        htmltext = event
      end
    when "32053-09.html"
      if qs.memo_state?(5) && has_quest_items?(player, ENGRAVED_HAMMER)
        qs.memo_state = 6
        qs.set_cond(6, true)
        htmltext = event
      end
    when "32054-02.html"
      if qs.memo_state?(9)
        htmltext = event
      end
    when "32054-03.html"
      if qs.memo_state?(9)
        give_adena(player, 17647, true)
        add_exp_and_sp(player, 107387, 7369)
        qs.exit_quest(false, true)
        htmltext = event
      end
    when "32055-02.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        htmltext = event
      end
    when "32055-05.html"
      if qs.memo_state?(8)
        if has_quest_items?(player, ENGRAVED_HAMMER)
          qs.memo_state = 9
          qs.set_cond(10, true)
          take_items(player, ENGRAVED_HAMMER, -1)
          htmltext = event
        else
          htmltext = "32055-06.html"
        end
      end
    when "32076-02.html"
      if qs.memo_state?(4)
        qs.memo_state = 5
        qs.set_cond(5, true)
        give_items(player, ENGRAVED_HAMMER, 1)
        htmltext = event
      end
    when "32052-02.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        htmltext = event
      end
    when "32052-05.html"
      if qs.memo_state?(6)
        qs.memo_state = 7
        qs.set_cond(7, true)
        htmltext = event
      end
    when "32052-07.html"
      if qs.memo_state?(7) && has_quest_items?(player, BOOK_OF_GREY_STAR)
        qs.memo_state = 8
        qs.set_cond(9, true)
        take_items(player, BOOK_OF_GREY_STAR, -1)
        htmltext = event
      end
    end

    htmltext
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

  def on_talk(npc, player)
    qs = get_quest_state!(player)

    if qs.completed?
      if npc.id == ABEY
        htmltext = get_already_completed_msg(player)
      end
    elsif qs.created?
      htmltext = player.level >= MIN_LEVEL ? "32053-01.htm" : "32053-03.htm"
    elsif qs.started?
      case npc.id
      when ABEY
        case qs.memo_state
        when 1
          htmltext = "32053-04.html"
        when 3
          htmltext = "32053-05.html"
        when 4
          htmltext = "32053-07.html"
        when 5
          if has_quest_items?(player, ENGRAVED_HAMMER)
            htmltext = "32053-08.html"
          end
        when 6
          htmltext = "32053-10.html"
        end
      when GHOST_OF_A_RAILROAD_ENGINEER
        if qs.memo_state?(9)
          htmltext = "32054-01.html"
      end
      when GHOST_OF_AN_ANCIENT_RAILROAD_ENGINEER
        case qs.memo_state
        when 1
          htmltext = "32055-01.html"
        when 2
          htmltext = "32055-03.html"
        when 8
          htmltext = "32055-04.html"
        when 9
          htmltext = "32055-07.html"
        end
      when BOX
        if qs.memo_state?(4)
          htmltext = "32076-01.html"
        elsif qs.memo_state?(5)
          htmltext = "32076-03.html"
        end
      when OBI
        case qs.memo_state
        when 2
          htmltext = "32052-01.html"
        when 3
          htmltext = "32052-03.html"
        when 6
          htmltext = "32052-04.html"
        when 7
          if has_quest_items?(player, BOOK_OF_GREY_STAR)
            htmltext = "32052-06.html"
          else
            htmltext = "32052-08.html"
          end
        when 8
          htmltext = "32052-09.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
