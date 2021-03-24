class Scripts::Q00212_TrialOfDuty < Quest
  # NPCs
  private HANNAVALT = 30109
  private DUSTIN = 30116
  private SIR_COLLIN_WINDAWOOD = 30311
  private SIR_ARON_TANFORD = 30653
  private SIR_KIEL_NIGHTHAWK = 30654
  private ISAEL_SILVERSHADOW = 30655
  private SPIRIT_OF_SIR_TALIANUS = 30656
  # Items
  private LETTER_OF_DUSTIN = 2634
  private KNIGHTS_TEAR = 2635
  private MIRROR_OF_ORPIC = 2636
  private TEAR_OF_CONFESSION = 2637
  private REPORT_PIECE = ItemHolder.new(2638, 10)
  private TALIANUSS_REPORT = 2639
  private TEAR_OF_LOYALTY = 2640
  private MILITAS_ARTICLE = ItemHolder.new(2641, 20)
  private SAINTS_ASHES_URN = 2641
  private ATHEBALDTS_SKULL = 2643
  private ATHEBALDTS_RIBS = 2644
  private ATHEBALDTS_SHIN = 2645
  private LETTER_OF_WINDAWOOD = 2646
  private OLD_KNIGHTS_SWORD = 3027
  # Monsters
  private HANGMAN_TREE = 20144
  private SKELETON_MARAUDER = 20190
  private SKELETON_RAIDER = 20191
  private STRAIN = 20200
  private GHOUL = 20201
  private BREKA_ORC_OVERLORD = 20270
  private LETO_LIZARDMAN = 20577
  private LETO_LIZARDMAN_ARCHER = 20578
  private LETO_LIZARDMAN_SOLDIER = 20579
  private LETO_LIZARDMAN_WARRIOR = 20580
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OVERLORD = 20582
  private SPIRIT_OF_SIR_HEROD = 27119
  # Rewards
  private MARK_OF_DUTY = 2633
  private DIMENSIONAL_DIAMOND = 7562
  # Misc
  private MIN_LEVEL = 35

  def initialize
    super(212, self.class.simple_name, "Trial of Duty")

    add_start_npc(HANNAVALT)
    add_talk_id(
      HANNAVALT, DUSTIN, SIR_COLLIN_WINDAWOOD, SIR_ARON_TANFORD,
      SIR_KIEL_NIGHTHAWK, ISAEL_SILVERSHADOW, SPIRIT_OF_SIR_TALIANUS
    )
    add_kill_id(
      HANGMAN_TREE, SKELETON_MARAUDER, SKELETON_RAIDER, STRAIN, GHOUL,
      BREKA_ORC_OVERLORD, LETO_LIZARDMAN, LETO_LIZARDMAN_ARCHER,
      LETO_LIZARDMAN_SOLDIER, LETO_LIZARDMAN_WARRIOR, LETO_LIZARDMAN_SHAMAN,
      LETO_LIZARDMAN_OVERLORD, SPIRIT_OF_SIR_HEROD
    )
    register_quest_items(
      LETTER_OF_DUSTIN, KNIGHTS_TEAR, MIRROR_OF_ORPIC, TEAR_OF_CONFESSION,
      REPORT_PIECE.id, TALIANUSS_REPORT, TEAR_OF_LOYALTY, MILITAS_ARTICLE.id,
      SAINTS_ASHES_URN, ATHEBALDTS_SKULL, ATHEBALDTS_RIBS, ATHEBALDTS_SHIN,
      LETTER_OF_WINDAWOOD, OLD_KNIGHTS_SWORD
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))
    html = nil

    case event
    when "quest_accept"
      if qs.created? && pc.level >= MIN_LEVEL && pc.in_category?(CategoryType::KNIGHT_GROUP)
        qs.start_quest
        qs.memo_state = 1
        qs.set("flag", 0)

        if reward_dimensional_diamonds(pc)
          html = "30109-04a.htm"
        else
          html = "30109-04.htm"
        end
      end
    when "30116-02.html", "30116-03.html", "30116-04.html"
      if qs.memo_state?(10) && has_quest_items?(pc, TEAR_OF_LOYALTY)
        html = event
      end
    when "30116-05.html"
      if qs.memo_state?(10) && has_quest_items?(pc, TEAR_OF_LOYALTY)
        html = event
        take_items(pc, TEAR_OF_LOYALTY, -1)
        qs.memo_state = 11
        qs.set_cond(14, true)
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs.nil? || !Util.in_range?(1500, killer, npc, true)
      return super
    end

    case npc.id
    when SKELETON_MARAUDER, SKELETON_RAIDER
      if qs.memo_state?(2)
        flag = qs.get_int("flag")

        if Rnd.rand(100) < flag * 10
          add_spawn(SPIRIT_OF_SIR_HEROD, npc)
          qs.set("flag", 0)
        else
          qs.set("flag", flag + 1)
        end
      end
    when SPIRIT_OF_SIR_HEROD
      if qs.memo_state?(2)
        weapon = killer.active_weapon_item

        if weapon && weapon.id == OLD_KNIGHTS_SWORD
          give_items(killer, KNIGHTS_TEAR, 1)
          qs.memo_state = 3
          qs.set_cond(3, true)
        end
      end
    when STRAIN, GHOUL
      if qs.memo_state?(5) && !has_quest_items?(killer, TALIANUSS_REPORT)
        if give_item_randomly(killer, npc, REPORT_PIECE.id, 1, REPORT_PIECE.count, 1, true)
          take_item(killer, REPORT_PIECE)
          give_items(killer, TALIANUSS_REPORT, 1)
          qs.set_cond(6)
        end
      end
    when HANGMAN_TREE
      if qs.memo_state?(6)
        flag = qs.get_int("flag")

        if Rnd.rand(100) < (flag - 3) * 33
          add_spawn(SPIRIT_OF_SIR_TALIANUS, npc)
          qs.set("flag", 0)
          qs.set_cond(8, true)
        else
          qs.set("flag", flag + 1)
        end
      end
    when LETO_LIZARDMAN, LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER,
         LETO_LIZARDMAN_WARRIOR, LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD
      if qs.memo_state?(9) && give_item_randomly(killer, npc, MILITAS_ARTICLE.id, 1, MILITAS_ARTICLE.count, 1, true)
        qs.set_cond(12)
      end
    when BREKA_ORC_OVERLORD
      if qs.memo_state?(11)
        if !has_quest_items?(killer, ATHEBALDTS_SKULL)
          give_items(killer, ATHEBALDTS_SKULL, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        elsif !has_quest_items?(killer, ATHEBALDTS_RIBS)
          give_items(killer, ATHEBALDTS_RIBS, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        elsif !has_quest_items?(killer, ATHEBALDTS_SHIN)
          give_items(killer, ATHEBALDTS_SHIN, 1)
          qs.set_cond(15, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when HANNAVALT
      if qs.created?
        if !pc.in_category?(CategoryType::KNIGHT_GROUP)
          html = "30109-02.html"
        elsif pc.level < MIN_LEVEL
          html = "30109-01.html"
        else
          html = "30109-03.htm"
        end
      elsif qs.started?
        case qs.memo_state
        when 1
          html = "30109-04.htm"
        when 14
          if has_quest_items?(pc, LETTER_OF_DUSTIN)
            html = "30109-05.html"
            take_items(pc, LETTER_OF_DUSTIN, -1)
            add_exp_and_sp(pc, 762576, 49458)
            give_adena(pc, 138968, true)
            give_items(pc, MARK_OF_DUTY, 1)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            reward_dimensional_diamonds(pc)
          end
        end
      else
        html = get_already_completed_msg(pc)
      end
    when SIR_ARON_TANFORD
      case qs.memo_state
      when 1
        html = "30653-01.html"

        unless has_quest_items?(pc, OLD_KNIGHTS_SWORD)
          give_items(pc, OLD_KNIGHTS_SWORD, 1)
        end

        qs.memo_state = 2
        qs.set_cond(2, true)
      when 2
        if has_quest_items?(pc, OLD_KNIGHTS_SWORD)
          html = "30653-02.html"
        end
      when 3
        if has_quest_items?(pc, KNIGHTS_TEAR)
          html = "30653-03.html"
          take_items(pc, -1, {KNIGHTS_TEAR, OLD_KNIGHTS_SWORD})
          qs.memo_state = 4
          qs.set_cond(4, true)
        end
      when 4
        html = "30653-04.html"
      end
    when SIR_KIEL_NIGHTHAWK
      case qs.memo_state
      when 4
        html = "30654-01.html"
        qs.memo_state = 5
        qs.set_cond(5, true)
      when 5
        if !has_quest_items?(pc, TALIANUSS_REPORT)
          html = "30654-02.html"
        else
          html = "30654-03.html"
          qs.memo_state = 6
          qs.set_cond(7, true)
          give_items(pc, MIRROR_OF_ORPIC, 1)
        end
      when 6
        if has_quest_items?(pc, MIRROR_OF_ORPIC)
          html = "30654-04.html"
        end
      when 7
        if has_quest_items?(pc, TEAR_OF_CONFESSION)
          html = "30654-05.html"
          take_items(pc, TEAR_OF_CONFESSION, -1)
          qs.memo_state = 8
          qs.set_cond(10, true)
        end
      when 8
        html = "30654-06.html"
      end
    when SPIRIT_OF_SIR_TALIANUS
      if qs.memo_state?(6)
        if has_quest_items?(pc, MIRROR_OF_ORPIC, TALIANUSS_REPORT)
          html = "30656-01.html"
          take_items(pc, -1, {MIRROR_OF_ORPIC, TALIANUSS_REPORT})
          give_items(pc, TEAR_OF_CONFESSION, 1)
          qs.memo_state = 7
          qs.set_cond(9, true)
          npc.delete_me
        end
      end
    when ISAEL_SILVERSHADOW
      case qs.memo_state
      when 8
        if pc.level < MIN_LEVEL
          html = "30655-01.html"
        else
          html = "30655-02.html"
          qs.memo_state = 9
          qs.set_cond(11, true)
        end
      when 9
        if !has_item?(pc, MILITAS_ARTICLE)
          html = "30655-03.html"
        else
          html = "30655-04.html"
          give_items(pc, TEAR_OF_LOYALTY, 1)
          take_item(pc, MILITAS_ARTICLE)
          qs.memo_state = 10
          qs.set_cond(13, true)
        end
      when 10
        if has_quest_items?(pc, TEAR_OF_LOYALTY)
          html = "30655-05.html"
        end
      end
    when DUSTIN
      case qs.memo_state
      when 10
        if has_quest_items?(pc, TEAR_OF_LOYALTY)
          html = "30116-01.html"
        end
      when 11
        if !has_quest_items?(pc, ATHEBALDTS_SKULL, ATHEBALDTS_RIBS, ATHEBALDTS_SHIN)
          html = "30116-06.html"
        else
          html = "30116-07.html"
          take_items(pc, -1, {ATHEBALDTS_SKULL, ATHEBALDTS_RIBS, ATHEBALDTS_SHIN})
          give_items(pc, SAINTS_ASHES_URN, 1)
          qs.memo_state = 12
          qs.set_cond(16, true)
        end
      when 12
        if has_quest_items?(pc, SAINTS_ASHES_URN)
          html = "30116-09.html"
        end
      when 13
        if has_quest_items?(pc, LETTER_OF_WINDAWOOD)
          html = "30116-08.html"
          take_items(pc, LETTER_OF_WINDAWOOD, -1)
          give_items(pc, LETTER_OF_DUSTIN, 1)
          qs.memo_state = 14
          qs.set_cond(18, true)
        end
      when 14
        if has_quest_items?(pc, LETTER_OF_DUSTIN)
          html = "30116-10.html"
        end
      end
    when SIR_COLLIN_WINDAWOOD
      case qs.memo_state
      when 12
        if has_quest_items?(pc, SAINTS_ASHES_URN)
          html = "30311-01.html"
          take_items(pc, SAINTS_ASHES_URN, -1)
          give_items(pc, LETTER_OF_WINDAWOOD, 1)
          qs.memo_state = 13
          qs.set_cond(17, true)
        end
      when 13
        if has_quest_items?(pc, LETTER_OF_WINDAWOOD)
          html = "30311-02.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def reward_dimensional_diamonds(pc)
    vars = pc.variables

    if vars.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
      if pc.class_id.knight?
        reward_items(pc, DIMENSIONAL_DIAMOND, 45)
      else
        reward_items(pc, DIMENSIONAL_DIAMOND, 61)
      end

      vars["2ND_CLASS_DIAMOND_REWARD"] = 1
      return true
    end

    false
  end
end
