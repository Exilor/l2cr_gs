class Scripts::Q00418_PathOfTheArtisan < Quest
  # NPCs
  private BLACKSMITH_SILVERA = 30527
  private BLACKSMITH_PINTER = 30298
  private BLACKSMITH_KLUTO = 30317
  private IRON_GATES_LOCKIRIN = 30531
  private WAREHOUSE_KEEPER_RYDEL = 31956
  private MINERAL_TRADER_HITCHI = 31963
  private RAILROAD_WORKER_OBI = 32052
  # Items
  private SILVERYS_RING = 1632
  private PASS_1ST_CERTIFICATE = 1633
  private PASS_2ND_CERTIFICATE = 1634
  private BOOGLE_RATMAN_TOOTH = 1636
  private BOOGLE_RATMAN_LEADERS_TOOTH = 1637
  private KLUTOS_LETTER = 1638
  private FOOTPRINT_OF_THIEF = 1639
  private STOLEN_SECRET_BOX = 1640
  private SECRET_BOX = 1641
  # Reward
  private FINAL_PASS_CERTIFICATE = 1635
  # Monster
  private VUKU_ORC_FIGHTER = 20017
  private BOOGLE_RATMAN = 20389
  private BOOGLE_RATMAN_LEADER = 20390
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(418, self.class.simple_name, "Path Of The Artisan")

    add_start_npc(BLACKSMITH_SILVERA)
    add_talk_id(
      BLACKSMITH_SILVERA, BLACKSMITH_PINTER, BLACKSMITH_KLUTO,
      IRON_GATES_LOCKIRIN, WAREHOUSE_KEEPER_RYDEL, MINERAL_TRADER_HITCHI,
      RAILROAD_WORKER_OBI
    )
    add_kill_id(VUKU_ORC_FIGHTER, BOOGLE_RATMAN, BOOGLE_RATMAN_LEADER)
    register_quest_items(
      SILVERYS_RING, PASS_1ST_CERTIFICATE, PASS_2ND_CERTIFICATE,
      BOOGLE_RATMAN_TOOTH, BOOGLE_RATMAN_LEADERS_TOOTH, KLUTOS_LETTER,
      FOOTPRINT_OF_THIEF, STOLEN_SECRET_BOX, SECRET_BOX
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.dwarven_fighter?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, FINAL_PASS_CERTIFICATE)
            html = "30527-04.htm"
          else
            html = "30527-05.htm"
          end
        else
          html = "30527-03.htm"
        end
      elsif pc.class_id.artisan?
        html = "30527-02a.htm"
      else
        html = "30527-02.htm"
      end
    when "30527-06.htm"
      qs.start_quest
      give_items(pc, SILVERYS_RING, 1)
      html = event
    when "30527-08b.html"
      take_items(pc, SILVERYS_RING, 1)
      take_items(pc, BOOGLE_RATMAN_TOOTH, -1)
      take_items(pc, BOOGLE_RATMAN_LEADERS_TOOTH, -1)
      give_items(pc, PASS_1ST_CERTIFICATE, 1)
      qs.set_cond(3, true)
      html = event
    when "30527-08c.html"
      take_items(pc, SILVERYS_RING, 1)
      take_items(pc, BOOGLE_RATMAN_TOOTH, -1)
      take_items(pc, BOOGLE_RATMAN_LEADERS_TOOTH, -1)
      qs.memo_state = 10
      qs.set_cond(8, true)
      html = event
    when "30298-02.html", "30317-02.html", "30317-03.html", "30317-05.html",
         "30317-06.html", "30317-11.html", "30531-02.html", "30531-03.html",
         "30531-04.html", "31956-02.html", "31956-03.html", "32052-02.html",
         "32052-03.html", "32052-04.html", "32052-05.html", "32052-06.html",
         "32052-10.html", "32052-11.html", "32052-12.html"
      html = event
    when "30298-03.html"
      if has_quest_items?(pc, KLUTOS_LETTER)
        take_items(pc, KLUTOS_LETTER, 1)
        give_items(pc, FOOTPRINT_OF_THIEF, 1)
        qs.set_cond(5, true)
        html = event
      end
    when "30298-06.html"
      if has_quest_items?(pc, FOOTPRINT_OF_THIEF, STOLEN_SECRET_BOX)
        give_items(pc, PASS_2ND_CERTIFICATE, 1)
        take_items(pc, FOOTPRINT_OF_THIEF, 1)
        take_items(pc, STOLEN_SECRET_BOX, 1)
        give_items(pc, SECRET_BOX, 1)
        qs.set_cond(7, true)
        html = event
      end
    when "30317-04.html"
      give_items(pc, KLUTOS_LETTER, 1)
      qs.set_cond(4, true)
      html = event
    when "30317-07.html"
      give_items(pc, KLUTOS_LETTER, 1)
      qs.set_cond(4)
      html = event
    when "30317-10.html"
      if has_quest_items?(pc, PASS_2ND_CERTIFICATE, SECRET_BOX)
        give_adena(pc, 163800, true)
        give_items(pc, FINAL_PASS_CERTIFICATE, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 320534, 32452)
        elsif level == 19
          add_exp_and_sp(pc, 456128, 30150)
        else
          add_exp_and_sp(pc, 591724, 36848)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    when "30317-12.html"
      if has_quest_items?(pc, PASS_2ND_CERTIFICATE, SECRET_BOX)
        give_adena(pc, 81900, true)
        give_items(pc, FINAL_PASS_CERTIFICATE, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 11726)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 15075)
        else
          add_exp_and_sp(pc, 295862, 18424)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    when "30531-05.html"
      if qs.memo_state?(101)
        give_adena(pc, 81900, true)
        give_items(pc, FINAL_PASS_CERTIFICATE, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 11726)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 15075)
        else
          add_exp_and_sp(pc, 295862, 18424)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    when "31956-04.html"
      if qs.memo_state?(201)
        give_adena(pc, 81900, true)
        give_items(pc, FINAL_PASS_CERTIFICATE, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 11726)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 15075)
        else
          add_exp_and_sp(pc, 295862, 18424)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    when "31963-02.html", "31963-06.html"
      if qs.memo_state?(100)
        html = event
      end
    when "31963-03.html"
      if qs.memo_state?(100)
        qs.memo_state = 101
        qs.set_cond(10, true)
        html = event
      end
    when "31963-05.html"
      if qs.memo_state?(100)
        qs.memo_state = 102
        qs.set_cond(11, true)
        html = event
      end
    when "31963-07.html"
      if qs.memo_state?(100)
        qs.memo_state = 201
        qs.set_cond(12, true)
        html = event
      end
    when "31963-09.html"
      if qs.memo_state?(100)
        qs.memo_state = 202
        html = event
      end
    when "31963-10.html"
      if qs.memo_state?(202)
        give_adena(pc, 81900, true)
        give_items(pc, FINAL_PASS_CERTIFICATE, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 11726)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 15075)
        else
          add_exp_and_sp(pc, 295862, 18424)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    when "32052-07.html"
      if qs.memo_state?(10)
        qs.memo_state = 100
        qs.set_cond(9, true)
        html = event
      end
    when "32052-13.html"
      if qs.memo_state?(102)
        give_adena(pc, 81900, true)
        give_items(pc, FINAL_PASS_CERTIFICATE, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 11726)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 15075)
        else
          add_exp_and_sp(pc, 295862, 18424)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when VUKU_ORC_FIGHTER
        if has_quest_items?(killer, FOOTPRINT_OF_THIEF) && !has_quest_items?(killer, STOLEN_SECRET_BOX)
          if Rnd.rand(10) < 2
            give_items(killer, STOLEN_SECRET_BOX, 1)
            qs.set_cond(6, true)
          end
        end
      when BOOGLE_RATMAN
        if has_quest_items?(killer, SILVERYS_RING) && get_quest_items_count(killer, BOOGLE_RATMAN_TOOTH) < 10
          if Rnd.rand(10) < 7
            if get_quest_items_count(killer, BOOGLE_RATMAN_TOOTH) == 9
              give_items(killer, BOOGLE_RATMAN_TOOTH, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              if get_quest_items_count(killer, BOOGLE_RATMAN_LEADERS_TOOTH) >= 2
                qs.set_cond(2)
              end
            else
              give_items(killer, BOOGLE_RATMAN_TOOTH, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when BOOGLE_RATMAN_LEADER
        if has_quest_items?(killer, SILVERYS_RING) && get_quest_items_count(killer, BOOGLE_RATMAN_LEADERS_TOOTH) < 2
          if Rnd.rand(10) < 5
            if get_quest_items_count(killer, BOOGLE_RATMAN_LEADERS_TOOTH) == 1
              give_items(killer, BOOGLE_RATMAN_LEADERS_TOOTH, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              if get_quest_items_count(killer, BOOGLE_RATMAN_TOOTH) >= 10
                qs.set_cond(2)
              end
            end
          else
            give_items(killer, BOOGLE_RATMAN_LEADERS_TOOTH, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == BLACKSMITH_SILVERA
        html = "30527-01.htm"
      end
    elsif qs.started?
      case npc.id
      when BLACKSMITH_SILVERA
        if has_quest_items?(pc, SILVERYS_RING) && ((get_quest_items_count(pc, BOOGLE_RATMAN_TOOTH) + get_quest_items_count(pc, BOOGLE_RATMAN_LEADERS_TOOTH)) < 12)
          html = "30527-07.html"
        elsif has_quest_items?(pc, SILVERYS_RING) && get_quest_items_count(pc, BOOGLE_RATMAN_TOOTH) >= 10 && get_quest_items_count(pc, BOOGLE_RATMAN_LEADERS_TOOTH) >= 2
          html = "30527-08a.html"
        elsif has_quest_items?(pc, PASS_1ST_CERTIFICATE)
          html = "30527-09.html"
        elsif !has_quest_items?(pc, PASS_1ST_CERTIFICATE) && qs.memo_state?(10)
          html = "30527-09a.html"
        end
      when BLACKSMITH_PINTER
        if has_quest_items?(pc, PASS_1ST_CERTIFICATE, KLUTOS_LETTER)
          html = "30298-01.html"
        elsif has_quest_items?(pc, PASS_1ST_CERTIFICATE, FOOTPRINT_OF_THIEF) && !has_quest_items?(pc, STOLEN_SECRET_BOX)
          html = "30298-04.html"
        elsif has_quest_items?(pc, PASS_1ST_CERTIFICATE, FOOTPRINT_OF_THIEF, STOLEN_SECRET_BOX)
          html = "30298-05.html"
        elsif has_quest_items?(pc, PASS_1ST_CERTIFICATE, PASS_2ND_CERTIFICATE, SECRET_BOX)
          html = "30298-07.html"
        end
      when BLACKSMITH_KLUTO
        if has_quest_items?(pc, PASS_1ST_CERTIFICATE) && !has_at_least_one_quest_item?(pc, FOOTPRINT_OF_THIEF, KLUTOS_LETTER, PASS_2ND_CERTIFICATE, SECRET_BOX)
          html = "30317-01.html"
        elsif has_quest_items?(pc, PASS_1ST_CERTIFICATE) && has_at_least_one_quest_item?(pc, KLUTOS_LETTER, FOOTPRINT_OF_THIEF)
          html = "30317-08.html"
        elsif has_quest_items?(pc, PASS_1ST_CERTIFICATE, PASS_2ND_CERTIFICATE, SECRET_BOX)
          html = "30317-09.html"
        end
      when IRON_GATES_LOCKIRIN
        if qs.memo_state?(101)
          html = "30531-01.html"
        end
      when WAREHOUSE_KEEPER_RYDEL
        if qs.memo_state?(201)
          html = "31956-01.html"
        end
      when MINERAL_TRADER_HITCHI
        case qs.memo_state
        when 100
          html = "31963-01.html"
        when 101
          html = "31963-04.html"
        when 102
          html = "31963-06a.html"
        when 201
          html = "31963-08.html"
        when 202
          html = "31963-11.html"
        end
      when RAILROAD_WORKER_OBI
        case qs.memo_state
        when 10
          html = "32052-01.html"
        when 100
          html = "32052-08.html"
        when 102
          html = "32052-09.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
