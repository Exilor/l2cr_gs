class Quests::Q00410_PathOfThePalusKnight < Quest
  # NPCs
  private MASTER_VIRGIL = 30329
  private KALINTA = 30422
  # Items
  private PALLUS_TALISMAN = 1237
  private LYCANTHROPE_SKULL = 1238
  private VIRGILS_LETTER = 1239
  private MORTE_TALISMAN = 1240
  private VENOMOUS_SPIDERS_CARAPACE = 1241
  private ARACHNID_TRACKER_SILK = 1242
  private COFFIN_OF_ETERNAL_REST = 1243
  # Reward
  private GAZE_OF_ABYSS = 1244
  # Monster
  private VENOMOUS_SPIDER = 20038
  private ARACHNID_TRACKER = 20043
  private LYCANTHROPE = 20049
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(410, self.class.simple_name, "Path Of The Palus Knight")

    add_start_npc(MASTER_VIRGIL)
    add_talk_id(MASTER_VIRGIL, KALINTA)
    add_kill_id(VENOMOUS_SPIDER, ARACHNID_TRACKER, LYCANTHROPE)
    register_quest_items(
      PALLUS_TALISMAN, LYCANTHROPE_SKULL, VIRGILS_LETTER, MORTE_TALISMAN,
      VENOMOUS_SPIDERS_CARAPACE, ARACHNID_TRACKER_SILK, COFFIN_OF_ETERNAL_REST
    )
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if player.class_id.dark_fighter?
        if player.level >= MIN_LEVEL
          if has_quest_items?(player, GAZE_OF_ABYSS)
            htmltext = "30329-04.htm"
          else
            htmltext = "30329-05.htm"
          end
        else
          htmltext = "30329-02.htm"
        end
      elsif player.class_id.palus_knight?
        htmltext = "30329-02a.htm"
      else
        htmltext = "30329-03.htm"
      end
    when "30329-06.htm"
      qs.start_quest
      give_items(player, PALLUS_TALISMAN, 1)
      htmltext = event
    when "30329-10.html"
      if has_quest_items?(player, PALLUS_TALISMAN, LYCANTHROPE_SKULL)
        take_items(player, PALLUS_TALISMAN, 1)
        take_items(player, LYCANTHROPE_SKULL, -1)
        give_items(player, VIRGILS_LETTER, 1)
        qs.set_cond(3, true)
        htmltext = event
      end
    when "30422-02.html"
      if has_quest_items?(player, VIRGILS_LETTER)
        take_items(player, VIRGILS_LETTER, 1)
        give_items(player, MORTE_TALISMAN, 1)
        qs.set_cond(4, true)
        htmltext = event
      end
    when "30422-06.html"
      if has_quest_items?(player, MORTE_TALISMAN, ARACHNID_TRACKER_SILK, VENOMOUS_SPIDERS_CARAPACE)
        take_items(player, MORTE_TALISMAN, 1)
        take_items(player, VENOMOUS_SPIDERS_CARAPACE, 1)
        take_items(player, ARACHNID_TRACKER_SILK, -1)
        give_items(player, COFFIN_OF_ETERNAL_REST, 1)
        qs.set_cond(6, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when VENOMOUS_SPIDER
        if has_quest_items?(killer, MORTE_TALISMAN) && get_quest_items_count(killer, VENOMOUS_SPIDERS_CARAPACE) < 1
          give_items(killer, VENOMOUS_SPIDERS_CARAPACE, 1)
          if get_quest_items_count(killer, ARACHNID_TRACKER_SILK) >= 5
            qs.set_cond(5, true)
          end
        end
      when ARACHNID_TRACKER
        if has_quest_items?(killer, MORTE_TALISMAN) && get_quest_items_count(killer, ARACHNID_TRACKER_SILK) < 5
          give_items(killer, ARACHNID_TRACKER_SILK, 1)
          if get_quest_items_count(killer, ARACHNID_TRACKER_SILK) == 5
            if get_quest_items_count(killer, ARACHNID_TRACKER_SILK) >= 4 && has_quest_items?(killer, VENOMOUS_SPIDERS_CARAPACE)
              qs.set_cond(5, true)
            end
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LYCANTHROPE
        if has_quest_items?(killer, PALLUS_TALISMAN) && get_quest_items_count(killer, LYCANTHROPE_SKULL) < 13
          give_items(killer, LYCANTHROPE_SKULL, 1)
          if get_quest_items_count(killer, LYCANTHROPE_SKULL) == 13
            qs.set_cond(2, true)
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
      if npc.id == MASTER_VIRGIL
        htmltext = "30329-01.htm"
      end
    elsif qs.started?
      case npc.id
      when MASTER_VIRGIL
        if has_quest_items?(player, PALLUS_TALISMAN)
          if !has_quest_items?(player, LYCANTHROPE_SKULL)
            htmltext = "30329-07.html"
          elsif has_quest_items?(player, LYCANTHROPE_SKULL) && get_quest_items_count(player, LYCANTHROPE_SKULL) < 13
            htmltext = "30329-08.html"
          else
            htmltext = "30329-09.html"
          end
        elsif has_quest_items?(player, COFFIN_OF_ETERNAL_REST)
          give_adena(player, 163800, true)
          give_items(player, GAZE_OF_ABYSS, 1)
          level = player.level
          if level >= 20
            add_exp_and_sp(player, 320534, 26212)
          elsif level == 19
            add_exp_and_sp(player, 456128, 32910)
          else
            add_exp_and_sp(player, 591724, 39608)
          end
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          htmltext = "30329-11.html"
        elsif has_at_least_one_quest_item?(player, VIRGILS_LETTER, MORTE_TALISMAN)
          htmltext = "30329-12.html"
        end
      when KALINTA
        if has_quest_items?(player, VIRGILS_LETTER)
          htmltext = "30422-01.html"
        elsif has_quest_items?(player, MORTE_TALISMAN)
          if !has_quest_items?(player, ARACHNID_TRACKER_SILK, VENOMOUS_SPIDERS_CARAPACE)
            htmltext = "30422-03.html"
          elsif !has_quest_items?(player, ARACHNID_TRACKER_SILK) && has_quest_items?(player, VENOMOUS_SPIDERS_CARAPACE)
            htmltext = "30422-04.html"
          elsif get_quest_items_count(player, ARACHNID_TRACKER_SILK) >= 5 && has_quest_items?(player, VENOMOUS_SPIDERS_CARAPACE)
            htmltext = "30422-05.html"
          elsif has_quest_items?(player, ARACHNID_TRACKER_SILK, VENOMOUS_SPIDERS_CARAPACE)
            htmltext = "30422-04.html"
          end
        elsif has_quest_items?(player, COFFIN_OF_ETERNAL_REST)
          htmltext = "30422-06.html"
        end
      end
    end

    htmltext
  end
end
