class Quests::Q00062_PathOfTheTrooper < Quest
  # NPCs
  private MASTER_SHUBAIN = 32194
  private MASTER_GWAIN = 32197
  # Items
  private FELIM_LIZARDMAN_HEAD = 9749
  private VENOMOUS_SPIDERS_LEG = 9750
  private TUMRAN_BUGBEAR_HEART = 9751
  private SHUBAINS_RECOMMENDATION = 9752
  # Reward
  private GWAINS_RECOMMENDATION = 9753
  # Monster
  private FELIM_LIZARDMAN_WARRIOR = 20014
  private VENOMOUS_SPIDER = 20038
  private TUMRAN_BUGBEAR = 20062
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(62, self.class.simple_name, "Path Of The Trooper")

    add_start_npc(MASTER_GWAIN)
    add_talk_id(MASTER_GWAIN, MASTER_SHUBAIN)
    add_kill_id(FELIM_LIZARDMAN_WARRIOR, VENOMOUS_SPIDER, TUMRAN_BUGBEAR)
    register_quest_items(FELIM_LIZARDMAN_HEAD, VENOMOUS_SPIDERS_LEG, TUMRAN_BUGBEAR_HEART, SHUBAINS_RECOMMENDATION)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        htmltext = "32197-06.htm"
      end
    when "32194-02.html"
      if qs.cond?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when FELIM_LIZARDMAN_WARRIOR
        if qs.cond?(2) && get_quest_items_count(killer, FELIM_LIZARDMAN_HEAD) < 5
          give_items(killer, FELIM_LIZARDMAN_HEAD, 1)
          if get_quest_items_count(killer, FELIM_LIZARDMAN_HEAD) == 5
            play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when VENOMOUS_SPIDER
        if qs.cond?(3) && get_quest_items_count(killer, VENOMOUS_SPIDERS_LEG) < 10
          give_items(killer, VENOMOUS_SPIDERS_LEG, 1)
          if get_quest_items_count(killer, VENOMOUS_SPIDERS_LEG) == 10
            play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when TUMRAN_BUGBEAR
        if qs.cond?(5) && !has_quest_items?(killer, TUMRAN_BUGBEAR_HEART)
          if Rnd.rand(1000) < 500
            give_items(killer, TUMRAN_BUGBEAR_HEART, 1)
            play_sound(qs.player, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)

    if qs.created?
      if npc.id == MASTER_GWAIN
        if player.race.kamael?
          if player.class_id.male_soldier?
            if player.level >= MIN_LEVEL
              htmltext = "32197-01.htm"
            else
              htmltext = "32197-02.html"
            end
          else
            htmltext = "32197-03.html"
          end
        else
          htmltext = "32197-04.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_GWAIN
        case qs.cond
        when 1, 2, 3
          htmltext = "32197-07.html"
        when 4
          take_items(player, SHUBAINS_RECOMMENDATION, 1)
          qs.memo_state = 5
          qs.set_cond(5, true)
          htmltext = "32197-08.html"
        when 5
          if !has_quest_items?(player, TUMRAN_BUGBEAR_HEART)
            htmltext = "32197-09.html"
          else
            give_adena(player, 163800, true)
            take_items(player, TUMRAN_BUGBEAR_HEART, 1)
            give_items(player, GWAINS_RECOMMENDATION, 1)
            level = player.level
            if level >= 20
              add_exp_and_sp(player, 320534, 20848)
            elsif level == 19
              add_exp_and_sp(player, 456128, 27546)
            else
              add_exp_and_sp(player, 591724, 34244)
            end
            qs.exit_quest(false, true)
            player.send_packet(SocialAction.new(player.l2id, 3))
            qs.save_global_quest_var("1ClassQuestFinished", "1")
            htmltext = "32197-10.html"
          end
        end
      when MASTER_SHUBAIN
        case qs.cond
        when 1
          htmltext = "32194-01.html"
        when 2
          if get_quest_items_count(player, FELIM_LIZARDMAN_HEAD) < 5
            htmltext = "32194-03.html"
          else
            take_items(player, FELIM_LIZARDMAN_HEAD, -1)
            qs.memo_state = 3
            qs.set_cond(3, true)
            htmltext = "32194-04.html"
          end
        when 3
          if get_quest_items_count(player, VENOMOUS_SPIDERS_LEG) < 10
            htmltext = "32194-05.html"
          else
            take_items(player, VENOMOUS_SPIDERS_LEG, -1)
            give_items(player, SHUBAINS_RECOMMENDATION, 1)
            qs.memo_state = 4
            qs.set_cond(4, true)
            htmltext = "32194-06.html"
          end
        when 4
          htmltext = "32194-07.html"
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_GWAIN
        htmltext = "32197-05.html"
      end
    end

    htmltext
  end
end
