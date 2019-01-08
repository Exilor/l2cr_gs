class Quests::Q00413_PathOfTheShillienOracle < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if player.class_id.dark_mage?
        if player.level >= MIN_LEVEL
          if has_quest_items?(player, ORB_OF_ABYSS)
            htmltext = "30330-04.htm"
          else
            htmltext = "30330-05.htm"
          end
        else
          htmltext = "30330-02.htm"
        end
      elsif player.class_id.shillien_oracle?
        htmltext = "30330-02a.htm"
      else
        htmltext = "30330-03.htm"
      end
    when "30330-06.htm"
      if !has_quest_items?(player, SIDRAS_LETTER)
        give_items(player, SIDRAS_LETTER, 1)
      end
      qs.start_quest
      htmltext = event
    when "30330-06a.html", "30375-02.html", "30375-03.html"
      htmltext = event
    when "30375-04.html"
      if has_quest_items?(player, PRAYER_OF_ADONIUS)
        take_items(player, PRAYER_OF_ADONIUS, 1)
        give_items(player, PENITENTS_MARK, 1)
        qs.set_cond(5, true)
      end
      htmltext = event
    when "30377-02.html"
      if has_quest_items?(player, SIDRAS_LETTER)
        take_items(player, SIDRAS_LETTER, 1)
        give_items(player, BLANK_SHEET, 5)
        qs.set_cond(2, true)
      end
      htmltext = event
    end

    htmltext
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
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created? || qs.completed?
      if npc.id == MAGISTER_SIDRA
        htmltext = "30330-01.htm"
      end
    elsif qs.started?
      case npc.id
      when MAGISTER_SIDRA
        if has_quest_items?(player, SIDRAS_LETTER)
          htmltext = "30330-07.html"
        elsif has_at_least_one_quest_item?(player, BLANK_SHEET, BLOODY_RUNE)
          htmltext = "30330-08.html"
        elsif !has_quest_items?(player, ANDARIEL_BOOK) && has_at_least_one_quest_item?(player, PRAYER_OF_ADONIUS, GARMIELS_BOOK, PENITENTS_MARK, ASHEN_BONES)
          htmltext = "30330-09.html"
        elsif has_at_least_one_quest_item?(player, ANDARIEL_BOOK, GARMIELS_BOOK)
          give_adena(player, 163800, true)
          give_items(player, ORB_OF_ABYSS, 1)
          level = player.level
          if level >= 20
            add_exp_and_sp(player, 320534, 26532)
          elsif level == 19
            add_exp_and_sp(player, 456128, 33230)
          else
            add_exp_and_sp(player, 591724, 39928)
          end
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          htmltext = "30330-10.html"
        end
      when PRIEST_ADONIUS
        if has_quest_items?(player, PRAYER_OF_ADONIUS)
          htmltext = "30375-01.html"
        elsif has_quest_items?(player, PENITENTS_MARK) && !has_at_least_one_quest_item?(player, ASHEN_BONES, ANDARIEL_BOOK)
          htmltext = "30375-05.html"
        elsif has_quest_items?(player, PENITENTS_MARK)
          if has_quest_items?(player, ASHEN_BONES) && get_quest_items_count(player, ASHEN_BONES) < 10
            htmltext = "30375-06.html"
          else
            take_items(player, PENITENTS_MARK, 1)
            take_items(player, ASHEN_BONES, -1)
            give_items(player, ANDARIEL_BOOK, 1)
            qs.set_cond(7, true)
            htmltext = "30375-07.html"
          end
        elsif has_quest_items?(player, ANDARIEL_BOOK)
          htmltext = "30375-08.html"
        end
      when MAGISTER_TALBOT
        if has_quest_items?(player, SIDRAS_LETTER)
          htmltext = "30377-01.html"
        elsif !has_quest_items?(player, BLOODY_RUNE) && get_quest_items_count(player, BLANK_SHEET) == 5
          htmltext = "30377-03.html"
        elsif has_quest_items?(player, BLOODY_RUNE) && get_quest_items_count(player, BLOODY_RUNE) < 5
          htmltext = "30377-04.html"
        elsif get_quest_items_count(player, BLOODY_RUNE) >= 5
          take_items(player, BLOODY_RUNE, -1)
          give_items(player, GARMIELS_BOOK, 1)
          give_items(player, PRAYER_OF_ADONIUS, 1)
          qs.set_cond(4, true)
          htmltext = "30377-05.html"
        elsif has_at_least_one_quest_item?(player, PRAYER_OF_ADONIUS, PENITENTS_MARK, ASHEN_BONES)
          htmltext = "30377-06.html"
        elsif has_quest_items?(player, ANDARIEL_BOOK, GARMIELS_BOOK)
          htmltext = "30377-07.html"
        end
      end
    end

    htmltext
  end
end
