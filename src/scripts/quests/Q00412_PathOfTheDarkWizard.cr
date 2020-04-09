class Scripts::Q00412_PathOfTheDarkWizard < Quest
  # NPCs
  private CHARKEREN = 30415
  private ANNIKA = 30418
  private ARKENIA = 30419
  private VARIKA = 30421
  # Items
  private SEEDS_OF_ANGER = 1253
  private SEEDS_OF_DESPAIR = 1254
  private SEEDS_OF_HORROR = 1255
  private SEEDS_OF_LUNACY = 1256
  private FAMILYS_REMAINS = 1257
  private KNEE_BONE = 1259
  private HEART_OF_LUNACY = 1260
  private LUCKY_KEY = 1277
  private CANDLE = 1278
  private HUB_SCENT = 1279
  # Reward
  private JEWEL_OF_DARKNESS = 1261
  # Monster
  private MARSH_ZOMBIE = 20015
  private MISERY_SKELETON = 20022
  private SKELETON_SCOUT = 20045
  private SKELETON_HUNTER = 20517
  private SKELETON_HUNTER_ARCHER = 20518
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(412, self.class.simple_name, "Path Of The Dark Wizard")

    add_start_npc(VARIKA)
    add_talk_id(VARIKA, CHARKEREN, ANNIKA, ARKENIA)
    add_kill_id(
      MARSH_ZOMBIE, MISERY_SKELETON, SKELETON_SCOUT, SKELETON_HUNTER,
      SKELETON_HUNTER_ARCHER
    )
    register_quest_items(
      SEEDS_OF_ANGER, SEEDS_OF_DESPAIR, SEEDS_OF_HORROR, SEEDS_OF_LUNACY,
      FAMILYS_REMAINS, KNEE_BONE, HEART_OF_LUNACY, LUCKY_KEY, CANDLE, HUB_SCENT
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.dark_mage?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, JEWEL_OF_DARKNESS)
            html = "30421-04.htm"
          else
            qs.start_quest
            give_items(pc, SEEDS_OF_DESPAIR, 1)
            html = "30421-05.htm"
          end
        else
          html = "30421-02.htm"
        end
      elsif pc.class_id.dark_wizard?
        html = "30421-02a.htm"
      else
        html = "30421-03.htm"
      end
    when "30421-06.html"
      if has_quest_items?(pc, SEEDS_OF_ANGER)
        html = event
      else
        html = "30421-07.html"
      end
    when "30421-09.html"
      if has_quest_items?(pc, SEEDS_OF_HORROR)
        html = event
      else
        html = "30421-10.html"
      end
    when "30421-11.html"
      if has_quest_items?(pc, SEEDS_OF_LUNACY)
        html = event
      elsif !has_quest_items?(pc, SEEDS_OF_LUNACY) && has_quest_items?(pc, SEEDS_OF_DESPAIR)
        html = "30421-12.html"
      end
    when "30421-08.html", "30415-02.html"
      html = event
    when "30415-03.html"
      give_items(pc, LUCKY_KEY, 1)
      html = event
    when "30418-02.html"
      give_items(pc, CANDLE, 1)
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
      when MARSH_ZOMBIE
        if has_quest_items?(killer, LUCKY_KEY) && get_quest_items_count(killer, FAMILYS_REMAINS) < 3
          if Rnd.rand(2) == 0
            give_items(killer, FAMILYS_REMAINS, 1)
            if get_quest_items_count(killer, FAMILYS_REMAINS) == 3
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when MISERY_SKELETON, SKELETON_HUNTER, SKELETON_HUNTER_ARCHER
        if has_quest_items?(killer, CANDLE) && get_quest_items_count(killer, KNEE_BONE) < 2
          if Rnd.rand(2) == 0
            give_items(killer, KNEE_BONE, 1)
            if get_quest_items_count(killer, KNEE_BONE) == 2
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when SKELETON_SCOUT
        if has_quest_items?(killer, HUB_SCENT) && get_quest_items_count(killer, HEART_OF_LUNACY) < 3
          if Rnd.rand(2) == 0
            give_items(killer, HEART_OF_LUNACY, 1)
            if get_quest_items_count(killer, HEART_OF_LUNACY) == 3
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
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
      if npc.id == VARIKA
        if !has_quest_items?(pc, JEWEL_OF_DARKNESS)
          html = "30421-01.htm"
        else
          html = "30421-04.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when VARIKA
        if has_quest_items?(pc, SEEDS_OF_DESPAIR, SEEDS_OF_HORROR, SEEDS_OF_LUNACY, SEEDS_OF_ANGER)
          give_adena(pc, 163800, true)
          give_items(pc, JEWEL_OF_DARKNESS, 1)
          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 320534, 28630)
          elsif level == 19
            add_exp_and_sp(pc, 456128, 28630)
          else
            add_exp_and_sp(pc, 591724, 35328)
          end
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          html = "30421-13.html"
        elsif has_quest_items?(pc, SEEDS_OF_DESPAIR)
          if !has_at_least_one_quest_item?(pc, FAMILYS_REMAINS, LUCKY_KEY, CANDLE, HUB_SCENT, KNEE_BONE, HEART_OF_LUNACY)
            html = "30421-14.html"
          elsif !has_quest_items?(pc, SEEDS_OF_ANGER)
            html = "30421-08.html"
          elsif !has_quest_items?(pc, SEEDS_OF_HORROR)
            html = "30421-15.html"
          elsif !has_quest_items?(pc, SEEDS_OF_LUNACY)
            html = "30421-12.html"
          end
        end
      when CHARKEREN
        if !has_quest_items?(pc, SEEDS_OF_ANGER) && has_quest_items?(pc, SEEDS_OF_DESPAIR)
          if !has_at_least_one_quest_item?(pc, FAMILYS_REMAINS, LUCKY_KEY)
            html = "30415-01.html"
          elsif has_quest_items?(pc, LUCKY_KEY) && get_quest_items_count(pc, FAMILYS_REMAINS) < 3
            html = "30415-04.html"
          else
            give_items(pc, SEEDS_OF_ANGER, 1)
            take_items(pc, FAMILYS_REMAINS, -1)
            take_items(pc, LUCKY_KEY, 1)
            html = "30415-05.html"
          end
        else
          html = "30415-06.html"
        end
      when ANNIKA
        unless has_quest_items?(pc, SEEDS_OF_HORROR) && has_quest_items?(pc, SEEDS_OF_DESPAIR)
          if !has_at_least_one_quest_item?(pc, CANDLE, KNEE_BONE)
            html = "30418-01.html"
          elsif has_quest_items?(pc, CANDLE) && get_quest_items_count(pc, KNEE_BONE) < 2
            html = "30418-03.html"
          else
            give_items(pc, SEEDS_OF_HORROR, 1)
            take_items(pc, KNEE_BONE, -1)
            take_items(pc, CANDLE, 1)
            html = "30418-04.html"
          end
        end
      when ARKENIA
        if !has_quest_items?(pc, SEEDS_OF_LUNACY)
          if !has_at_least_one_quest_item?(pc, HUB_SCENT, HEART_OF_LUNACY)
            give_items(pc, HUB_SCENT, 1)
            html = "30419-01.html"
          elsif has_quest_items?(pc, HUB_SCENT) && get_quest_items_count(pc, HEART_OF_LUNACY) < 3
            html = "30419-02.html"
          else
            give_items(pc, SEEDS_OF_LUNACY, 1)
            take_items(pc, HEART_OF_LUNACY, -1)
            take_items(pc, HUB_SCENT, 1)
            html = "30419-03.html"
          end
        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
