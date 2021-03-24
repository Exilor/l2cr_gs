class Scripts::Q00063_PathOfTheWarder < Quest
  # NPCs
  private MASTER_SIONE = 32195
  private MASTER_GOBIE = 32198
  private MASTER_TOBIAS = 30297
  private CAPTAIN_BATHIS = 30332
  # Items
  private ORDERS = 9762
  private ORGANIZATION_CHART = 9763
  private GOBIES_ORDERS = 9764
  private LETTER_TO_HUMANS = 9765
  private HUMANS_REOLY = 9766
  private LETTER_TO_THE_DARKELVES = 9767
  private DARK_ELVES_REPLY = 9768
  private REPORT_TO_SIONE = 9769
  private EMPTY_SOUL_CRYSTAL = 9770
  private TAKS_CAPTURED_SOUL = 9771
  # Reward
  private STEELRAZOR_EVALUTION = 9772
  # Monster
  private OL_MAHUM_PATROL = 20053
  private OL_MAHUM_NOVICE = 20782
  private MAILLE_LIZARDMAN = 20919
  private MAILLE_LIZARDMAN_SCOUT = 20920
  private MAILLE_LIZARDMAN_GUARD = 20921
  # Quest Monster
  private OL_MAHUM_OFFICER_TAK = 27337
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(63, self.class.simple_name, "Path Of The Warder")

    add_start_npc(MASTER_SIONE)
    add_talk_id(MASTER_SIONE, MASTER_GOBIE, MASTER_TOBIAS, CAPTAIN_BATHIS)
    add_kill_id(
      OL_MAHUM_PATROL, OL_MAHUM_NOVICE, MAILLE_LIZARDMAN,
      MAILLE_LIZARDMAN_SCOUT, MAILLE_LIZARDMAN_GUARD, OL_MAHUM_OFFICER_TAK
    )
    register_quest_items(
      ORDERS, ORGANIZATION_CHART, GOBIES_ORDERS, LETTER_TO_HUMANS, HUMANS_REOLY,
      LETTER_TO_THE_DARKELVES, DARK_ELVES_REPLY, REPORT_TO_SIONE,
      EMPTY_SOUL_CRYSTAL, TAKS_CAPTURED_SOUL
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = "32195-05.htm"
      end
    when "32195-06.html"
      if qs.memo_state?(1)
        html = event
      end
    when "32195-08.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "32198-03.html"
      if qs.memo_state?(3)
        take_items(pc, GOBIES_ORDERS, 1)
        give_items(pc, LETTER_TO_HUMANS, 1)
        qs.memo_state = 4
        qs.set_cond(5, true)
        html = event
      end
    when "32198-07.html"
      if qs.memo_state?(7)
        html = event
      end
    when "32198-08.html"
      if qs.memo_state?(7)
        give_items(pc, LETTER_TO_THE_DARKELVES, 1)
        qs.memo_state = 8
        qs.set_cond(7, true)
        html = event
      end
    when "32198-12.html"
      if qs.memo_state?(12)
        give_items(pc, REPORT_TO_SIONE, 1)
        qs.memo_state = 13
        qs.set_cond(9, true)
        html = event
      end
    when "32198-15.html"
      if qs.memo_state?(14)
        qs.memo_state = 15
        html = event
      end
    when "32198-16.html"
      if qs.memo_state?(15)
        give_items(pc, EMPTY_SOUL_CRYSTAL, 1)
        qs.memo_state = 16
        qs.set("ex", 0)
        qs.set_cond(11, true)
        html = event
      end
    when "30332-03.html"
      if qs.memo_state?(4)
        take_items(pc, LETTER_TO_HUMANS, 1)
        give_items(pc, HUMANS_REOLY, 1)
        qs.memo_state = 5
        html = event
      end
    when "30332-05.html"
      if qs.memo_state?(5)
        html = event
      end
    when "30332-06.html"
      if qs.memo_state?(5)
        qs.memo_state = 6
        qs.set_cond(6, true)
        html = event
      end
    when "30297-03.html"
      if qs.memo_state?(9)
        html = event
      end
    when "30297-04.html"
      if qs.memo_state?(9)
        qs.memo_state = 10
        html = event
      end
    when "30297-06.html"
      if qs.memo_state?(10)
        give_items(pc, DARK_ELVES_REPLY, 1)
        qs.memo_state = 11
        qs.set_cond(8, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when OL_MAHUM_PATROL
        if qs.memo_state?(2) && get_quest_items_count(killer, ORGANIZATION_CHART) < 5
          if get_quest_items_count(killer, ORDERS) >= 10 && get_quest_items_count(killer, ORGANIZATION_CHART) >= 4
            qs.set_cond(3, true)
          else
            play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
          give_items(killer, ORGANIZATION_CHART, 1)
        end
      when OL_MAHUM_NOVICE
        if qs.memo_state?(2) && get_quest_items_count(killer, ORDERS) < 10
          if get_quest_items_count(killer, ORDERS) >= 9 && get_quest_items_count(killer, ORGANIZATION_CHART) >= 5
            qs.set_cond(3, true)
          else
            play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
          give_items(killer, ORDERS, 1)
        end
      when MAILLE_LIZARDMAN, MAILLE_LIZARDMAN_SCOUT, MAILLE_LIZARDMAN_GUARD
        if qs.memo_state?(16) && !has_quest_items?(killer, TAKS_CAPTURED_SOUL)
          i4 = qs.get_int("ex")
          if i4 < 4
            qs.set("ex", i4 &+ 1)
          else
            qs.set("ex", 0)
             monster = add_spawn(OL_MAHUM_OFFICER_TAK, npc, true, 0, false)
            add_attack_desire(monster, killer)
          end
        end
      when OL_MAHUM_OFFICER_TAK
        if qs.memo_state?(16) && !has_quest_items?(killer, TAKS_CAPTURED_SOUL)
          take_items(killer, EMPTY_SOUL_CRYSTAL, 1)
          give_items(killer, TAKS_CAPTURED_SOUL, 1)
          qs.set_cond(12, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == MASTER_SIONE
        if pc.class_id.female_soldier? && !has_quest_items?(pc, STEELRAZOR_EVALUTION)
          if pc.level >= MIN_LEVEL
            html = "32195-01.htm"
          else
            html = "32195-02.html"
          end
        elsif has_quest_items?(pc, STEELRAZOR_EVALUTION)
          html = "32195-03.html"
        else
          html = "32195-04.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_SIONE
        if memo_state == 1
          html = "32195-07.html"
        elsif memo_state == 2
          if get_quest_items_count(pc, ORDERS) < 10 || get_quest_items_count(pc, ORGANIZATION_CHART) < 5
            html = "32195-09.html"
          else
            take_items(pc, ORDERS, -1)
            take_items(pc, ORGANIZATION_CHART, -1)
            give_items(pc, GOBIES_ORDERS, 1)
            qs.memo_state = 3
            qs.set_cond(4, true)
            html = "32195-10.html"
          end
        elsif memo_state == 3
          html = "32195-11.html"
        elsif memo_state > 3 && memo_state != 13
          html = "32195-12.html"
        elsif memo_state == 13
          take_items(pc, REPORT_TO_SIONE, 1)
          qs.memo_state = 14
          qs.set_cond(10, true)
          html = "32195-13.html"
        end
      when MASTER_GOBIE
        if memo_state < 3
          html = "32198-01.html"
        elsif memo_state == 3
          html = "32198-02.html"
        elsif memo_state == 4 || memo_state == 5
          html = "32198-04.html"
        elsif memo_state == 6
          take_items(pc, HUMANS_REOLY, 1)
          qs.memo_state = 7
          html = "32198-05.html"
        elsif memo_state == 7
          html = "32198-06.html"
        elsif memo_state == 8
          html = "32198-09.html"
        elsif memo_state == 11
          take_items(pc, DARK_ELVES_REPLY, 1)
          qs.memo_state = 12
          html = "32198-10.html"
        elsif memo_state == 12
          give_items(pc, REPORT_TO_SIONE, 1)
          qs.memo_state = 13
          html = "32198-11.html"
        elsif memo_state == 13
          html = "32198-13.html"
        elsif memo_state == 14
          html = "32198-14.html"
        elsif memo_state == 15
          give_items(pc, EMPTY_SOUL_CRYSTAL, 1)
          qs.memo_state = 16
          qs.set("ex", 0)
          qs.set_cond(11, true)
          html = "32198-17.html"
        elsif memo_state == 16
          if !has_quest_items?(pc, TAKS_CAPTURED_SOUL)
            qs.set("ex", 0)
            html = "32198-18.html"
          else
            give_adena(pc, 163_800, true)
            take_items(pc, TAKS_CAPTURED_SOUL, 1)
            give_items(pc, STEELRAZOR_EVALUTION, 1)
            level = pc.level
            if level >= 20
              add_exp_and_sp(pc, 320_534, 22_046)
            elsif level == 19
              add_exp_and_sp(pc, 456_128, 28_744)
            else
              add_exp_and_sp(pc, 591_724, 35_442)
            end
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            qs.save_global_quest_var("1ClassQuestFinished", "1")
            html = "32198-19.html"
          end
        end
      when CAPTAIN_BATHIS
        if memo_state == 4
          html = "30332-01.html"
        elsif memo_state < 4
          html = "30332-02.html"
        elsif memo_state == 5
          html = "30332-04.html"
        elsif memo_state == 6
          html = "30332-07.html"
        elsif memo_state > 6
          html = "30332-08.html"
        end
      when MASTER_TOBIAS
        if memo_state == 8
          take_items(pc, LETTER_TO_THE_DARKELVES, 1)
          qs.memo_state = 9
          html = "30297-01.html"
        elsif memo_state == 9
          html = "30297-02.html"
        elsif memo_state == 10
          give_items(pc, DARK_ELVES_REPLY, 1)
          qs.memo_state = 11
          qs.set_cond(8, true)
          html = "30297-05.html"
        elsif memo_state >= 11
          html = "30297-07.html"
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_GOBIE
        if has_quest_items?(pc, STEELRAZOR_EVALUTION)
          html = "32198-20.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
