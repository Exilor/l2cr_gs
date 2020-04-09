class Scripts::Q00413_PathOfTheShillienOracle < Quest
  # NPCs
  private MAGISTER_SIDRA = 30330
  private PRIEST_ADONIUS = 30375
  private MAGISTER_TALBOT = 30377
  # Items
  private SIDRAS_LETTER = 1262
  private BLANK_SHEET = 1263
  private BLOODY_RUNE = 1264
  private GARMIELS_BOOK = 1265
  private PRAYER_OF_ADONIUS = 1266
  private PENITENTS_MARK = 1267
  private ASHEN_BONES = 1268
  private ANDARIEL_BOOK = 1269
  # Reward
  private ORB_OF_ABYSS = 1270
  # Monster
  private ZOMBIE_SOLDIER = 20457
  private ZOMBIE_WARRIOR = 20458
  private SHIELD_SKELETON = 20514
  private SKELETON_INFANTRYMAN = 20515
  private DARK_SUCCUBUS = 20776
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(413, self.class.simple_name, "Path of the Shillien Oracle")

    add_start_npc(MAGISTER_SIDRA)
    add_talk_id(MAGISTER_SIDRA, PRIEST_ADONIUS, MAGISTER_TALBOT)
    add_kill_id(
      ZOMBIE_SOLDIER, ZOMBIE_WARRIOR, SHIELD_SKELETON, SKELETON_INFANTRYMAN,
      DARK_SUCCUBUS
    )
    register_quest_items(
      SIDRAS_LETTER, BLANK_SHEET, BLOODY_RUNE, GARMIELS_BOOK,
      PRAYER_OF_ADONIUS, PENITENTS_MARK, ASHEN_BONES, ANDARIEL_BOOK
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.dark_mage?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, ORB_OF_ABYSS)
            html = "30330-04.htm"
          else
            html = "30330-05.htm"
          end
        else
          html = "30330-02.htm"
        end
      elsif pc.class_id.shillien_oracle?
        html = "30330-02a.htm"
      else
        html = "30330-03.htm"
      end
    when "30330-06.htm"
      if !has_quest_items?(pc, SIDRAS_LETTER)
        give_items(pc, SIDRAS_LETTER, 1)
      end
      qs.start_quest
      html = event
    when "30330-06a.html", "30375-02.html", "30375-03.html"
      html = event
    when "30375-04.html"
      if has_quest_items?(pc, PRAYER_OF_ADONIUS)
        take_items(pc, PRAYER_OF_ADONIUS, 1)
        give_items(pc, PENITENTS_MARK, 1)
        qs.set_cond(5, true)
      end
      html = event
    when "30377-02.html"
      if has_quest_items?(pc, SIDRAS_LETTER)
        take_items(pc, SIDRAS_LETTER, 1)
        give_items(pc, BLANK_SHEET, 5)
        qs.set_cond(2, true)
      end
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when ZOMBIE_SOLDIER, ZOMBIE_WARRIOR, SHIELD_SKELETON, SKELETON_INFANTRYMAN
        if has_quest_items?(killer, PENITENTS_MARK) && get_quest_items_count(killer, ASHEN_BONES) < 10
          give_items(killer, ASHEN_BONES, 1)
          if get_quest_items_count(killer, ASHEN_BONES) == 10
            qs.set_cond(6, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when DARK_SUCCUBUS
        if has_quest_items?(killer, BLANK_SHEET)
          give_items(killer, BLOODY_RUNE, 1)
          take_items(killer, BLANK_SHEET, 1)
          if !has_quest_items?(killer, BLANK_SHEET) && get_quest_items_count(killer, BLOODY_RUNE) == 5
            qs.set_cond(3, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == MAGISTER_SIDRA
        html = "30330-01.htm"
      end
    elsif qs.started?
      case npc.id
      when MAGISTER_SIDRA
        if has_quest_items?(pc, SIDRAS_LETTER)
          html = "30330-07.html"
        elsif has_at_least_one_quest_item?(pc, BLANK_SHEET, BLOODY_RUNE)
          html = "30330-08.html"
        elsif !has_quest_items?(pc, ANDARIEL_BOOK) && has_at_least_one_quest_item?(pc, PRAYER_OF_ADONIUS, GARMIELS_BOOK, PENITENTS_MARK, ASHEN_BONES)
          html = "30330-09.html"
        elsif has_at_least_one_quest_item?(pc, ANDARIEL_BOOK, GARMIELS_BOOK)
          give_adena(pc, 163800, true)
          give_items(pc, ORB_OF_ABYSS, 1)
          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 320534, 26532)
          elsif level == 19
            add_exp_and_sp(pc, 456128, 33230)
          else
            add_exp_and_sp(pc, 591724, 39928)
          end
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          html = "30330-10.html"
        end
      when PRIEST_ADONIUS
        if has_quest_items?(pc, PRAYER_OF_ADONIUS)
          html = "30375-01.html"
        elsif has_quest_items?(pc, PENITENTS_MARK) && !has_at_least_one_quest_item?(pc, ASHEN_BONES, ANDARIEL_BOOK)
          html = "30375-05.html"
        elsif has_quest_items?(pc, PENITENTS_MARK)
          if has_quest_items?(pc, ASHEN_BONES) && get_quest_items_count(pc, ASHEN_BONES) < 10
            html = "30375-06.html"
          else
            take_items(pc, PENITENTS_MARK, 1)
            take_items(pc, ASHEN_BONES, -1)
            give_items(pc, ANDARIEL_BOOK, 1)
            qs.set_cond(7, true)
            html = "30375-07.html"
          end
        elsif has_quest_items?(pc, ANDARIEL_BOOK)
          html = "30375-08.html"
        end
      when MAGISTER_TALBOT
        if has_quest_items?(pc, SIDRAS_LETTER)
          html = "30377-01.html"
        elsif !has_quest_items?(pc, BLOODY_RUNE) && get_quest_items_count(pc, BLANK_SHEET) == 5
          html = "30377-03.html"
        elsif has_quest_items?(pc, BLOODY_RUNE) && get_quest_items_count(pc, BLOODY_RUNE) < 5
          html = "30377-04.html"
        elsif get_quest_items_count(pc, BLOODY_RUNE) >= 5
          take_items(pc, BLOODY_RUNE, -1)
          give_items(pc, GARMIELS_BOOK, 1)
          give_items(pc, PRAYER_OF_ADONIUS, 1)
          qs.set_cond(4, true)
          html = "30377-05.html"
        elsif has_at_least_one_quest_item?(pc, PRAYER_OF_ADONIUS, PENITENTS_MARK, ASHEN_BONES)
          html = "30377-06.html"
        elsif has_quest_items?(pc, ANDARIEL_BOOK, GARMIELS_BOOK)
          html = "30377-07.html"
        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
