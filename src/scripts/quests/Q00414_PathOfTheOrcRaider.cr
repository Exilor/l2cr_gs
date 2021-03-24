class Scripts::Q00414_PathOfTheOrcRaider < Quest
  # NPCs
  private PREFECT_KARUKIA = 30570
  private PREFRCT_KASMAN = 30501
  private PREFRCT_TAZEER = 31978
  # Items
  private GREEN_BLOOD = 1578
  private GOBLIN_DWELLING_MAP = 1579
  private KURUKA_RATMAN_TOOTH = 1580
  private BETRAYER_UMBAR_REPORT = 1589
  private BETRAYER_ZAKAN_REPORT = 1590
  private HEAD_OF_BETRAYER = 1591
  private TIMORA_ORC_HEAD = 8544
  # Reward
  private MARK_OF_RAIDER = 1592
  # Quest Monster
  private KURUKA_RATMAN_LEADER = 27045
  private UMBAR_ORC = 27054
  private TIMORA_ORC = 27320
  # Monster
  private GOBLIN_TOMB_RAIDER_LEADER = 20320
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(414, self.class.simple_name, "Path Of The Orc Raider")

    add_start_npc(PREFECT_KARUKIA)
    add_talk_id(PREFECT_KARUKIA, PREFRCT_KASMAN, PREFRCT_TAZEER)
    add_kill_id(
      KURUKA_RATMAN_LEADER, UMBAR_ORC, TIMORA_ORC, GOBLIN_TOMB_RAIDER_LEADER
    )
    register_quest_items(
      GREEN_BLOOD, GOBLIN_DWELLING_MAP, KURUKA_RATMAN_TOOTH,
      BETRAYER_UMBAR_REPORT, BETRAYER_ZAKAN_REPORT, HEAD_OF_BETRAYER,
      TIMORA_ORC_HEAD
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "ACCEPT"
      if pc.class_id.orc_fighter?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, MARK_OF_RAIDER)
            html = "30570-04.htm"
          else
            unless has_quest_items?(pc, GOBLIN_DWELLING_MAP)
              give_items(pc, GOBLIN_DWELLING_MAP, 1)
            end
            qs.start_quest
            html = "30570-05.htm"
          end
        else
          html = "30570-02.htm"
        end
      elsif pc.class_id.orc_raider?
        html = "30570-02a.htm"
      else
        html = "30570-03.htm"
      end
    when "30570-07a.html"
      if has_quest_items?(pc, GOBLIN_DWELLING_MAP)
        if get_quest_items_count(pc, KURUKA_RATMAN_TOOTH) >= 10
          take_items(pc, GOBLIN_DWELLING_MAP, 1)
          take_items(pc, KURUKA_RATMAN_TOOTH, -1)
          give_items(pc, BETRAYER_UMBAR_REPORT, 1)
          give_items(pc, BETRAYER_ZAKAN_REPORT, 1)
          qs.set_cond(3, true)
          html = event
        end
      end
    when "30570-07b.html"
      if has_quest_items?(pc, GOBLIN_DWELLING_MAP)
        if get_quest_items_count(pc, KURUKA_RATMAN_TOOTH) >= 10
          take_items(pc, GOBLIN_DWELLING_MAP, 1)
          take_items(pc, KURUKA_RATMAN_TOOTH, -1)
          qs.set_cond(5, true)
          qs.memo_state = 2
          html = event
        end
      end
    when "31978-04.html"
      if qs.memo_state?(2)
        html = event
      end
    when "31978-02.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(6, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when GOBLIN_TOMB_RAIDER_LEADER
        if has_quest_items?(killer, GOBLIN_DWELLING_MAP)
          if get_quest_items_count(killer, KURUKA_RATMAN_TOOTH) < 10
            if get_quest_items_count(killer, GREEN_BLOOD) <= 20
              if Rnd.rand(100) < get_quest_items_count(killer, GREEN_BLOOD) &* 5
                take_items(killer, GREEN_BLOOD, -1)
                add_attack_desire(add_spawn(KURUKA_RATMAN_LEADER, npc, true, 0i64, true), killer)
              else
                give_items(killer, GREEN_BLOOD, 1)
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      when KURUKA_RATMAN_LEADER
        if has_quest_items?(killer, GOBLIN_DWELLING_MAP)
          if get_quest_items_count(killer, KURUKA_RATMAN_TOOTH) < 10
            take_items(killer, GREEN_BLOOD, -1)
            if get_quest_items_count(killer, KURUKA_RATMAN_TOOTH) >= 9
              give_items(killer, KURUKA_RATMAN_TOOTH, 1)
              qs.set_cond(2, true)
            else
              give_items(killer, KURUKA_RATMAN_TOOTH, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when UMBAR_ORC
        if has_at_least_one_quest_item?(killer, BETRAYER_UMBAR_REPORT, BETRAYER_ZAKAN_REPORT)
          if get_quest_items_count(killer, HEAD_OF_BETRAYER) < 2
            if Rnd.rand(10) < 2
              give_items(killer, HEAD_OF_BETRAYER, 1)
              if has_quest_items?(killer, BETRAYER_ZAKAN_REPORT)
                take_items(killer, BETRAYER_ZAKAN_REPORT, 1)
              elsif has_quest_items?(killer, BETRAYER_UMBAR_REPORT)
                take_items(killer, BETRAYER_UMBAR_REPORT, 1)
              end
              if get_quest_items_count(killer, HEAD_OF_BETRAYER) == 2
                qs.set_cond(4, true)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      when TIMORA_ORC
        if qs.memo_state?(3) && !has_quest_items?(killer, TIMORA_ORC_HEAD)
          if Rnd.rand(100) < 60
            give_items(killer, TIMORA_ORC_HEAD, 1)
            qs.set_cond(7, true)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    if qs.created? || qs.completed?
      if npc.id == PREFECT_KARUKIA
        html = "30570-01.htm"
      end
    elsif qs.started?
      case npc.id
      when PREFECT_KARUKIA
        if has_quest_items?(pc, GOBLIN_DWELLING_MAP) && get_quest_items_count(pc, KURUKA_RATMAN_TOOTH) < 10
          html = "30570-06.html"
        elsif has_quest_items?(pc, GOBLIN_DWELLING_MAP) && get_quest_items_count(pc, KURUKA_RATMAN_TOOTH) >= 10
          unless has_at_least_one_quest_item?(pc, BETRAYER_UMBAR_REPORT, BETRAYER_ZAKAN_REPORT)
            html = "30570-07.html"
          end
        elsif has_quest_items?(pc, HEAD_OF_BETRAYER) || has_at_least_one_quest_item?(pc, BETRAYER_UMBAR_REPORT, BETRAYER_ZAKAN_REPORT)
          html = "30570-08.html"
        elsif qs.memo_state?(2)
          html = "30570-07b.html"
        end
      when PREFRCT_KASMAN
        if !has_quest_items?(pc, HEAD_OF_BETRAYER) && get_quest_items_count(pc, BETRAYER_UMBAR_REPORT, BETRAYER_ZAKAN_REPORT) >= 2
          html = "30501-01.html"
        elsif get_quest_items_count(pc, HEAD_OF_BETRAYER) == 1
          html = "30501-02.html"
        elsif get_quest_items_count(pc, HEAD_OF_BETRAYER) == 2
          give_adena(pc, 163_800, true)
          give_items(pc, MARK_OF_RAIDER, 1)
          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 320_534, 21_312)
          elsif level == 19
            add_exp_and_sp(pc, 456_128, 28_010)
          else
            add_exp_and_sp(pc, 591_724, 34_708)
          end
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          html = "30501-03.html"
        end
      when PREFRCT_TAZEER
        if qs.memo_state?(2)
          html = "31978-01.html"
        elsif qs.memo_state?(3)
          if !has_quest_items?(pc, TIMORA_ORC_HEAD)
            html = "31978-03.html"
          else
            give_adena(pc, 81_900, true)
            give_items(pc, MARK_OF_RAIDER, 1)
            level = pc.level
            if level >= 20
              add_exp_and_sp(pc, 160_267, 10_656)
            elsif level == 19
              add_exp_and_sp(pc, 228_064, 14_005)
            else
              add_exp_and_sp(pc, 295_862, 17_354)
            end
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            qs.save_global_quest_var("1ClassQuestFinished", "1")
            html = "31978-05.html"
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
