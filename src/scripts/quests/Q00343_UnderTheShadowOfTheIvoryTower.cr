class Scripts::Q00343_UnderTheShadowOfTheIvoryTower < Quest
  # NPCs
  private MAGIC_TRADER_CEMA = 30834
  private LICH_KING_ICARUS = 30835
  private COLLECTOR_MARSHA = 30934
  private COLLECTOR_TRUMPIN = 30935
  # Item
  private NEBULITE_ORB = 4364
  # Rewards
  private TOWER_SHIELD = 103
  private NICKLACE_OF_MAGIC = 118
  private SAGES_BLOOD = 316
  private SQUARE_SHIELD = 630
  private SCROLL_OF_ESCAPE = 736
  private RING_OF_AGES = 885
  private NICKLACE_OF_MERMAID = 917
  private SCROLL_ENCHANT_WEAPON_C_GRADE = 951
  private SCROLL_ENCHANT_WEAPON_D_GRADE = 955
  private SPIRITSHOT_D_GRADE = 2510
  private SPIRITSHOT_C_GRADE = 2511
  private ECTOPLASM_LIQUEUR = 4365
  # Monster
  private MANASHEN_GARGOYLE = 20563
  private ENCHANTED_MONSTEREYE = 20564
  private ENCHANTED_STONE_GOLEM = 20565
  private ENCHANTED_IRON_GOLEM = 20566
  # Misc
  private MIN_LEVEL = 40

  def initialize
    super(343, self.class.simple_name, "Under The Shadow Of The Ivory Tower")

    add_start_npc(MAGIC_TRADER_CEMA)
    add_talk_id(
      MAGIC_TRADER_CEMA, LICH_KING_ICARUS, COLLECTOR_MARSHA, COLLECTOR_TRUMPIN
    )
    add_kill_id(
      MANASHEN_GARGOYLE, ENCHANTED_MONSTEREYE, ENCHANTED_STONE_GOLEM,
      ENCHANTED_IRON_GOLEM
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30834-05.htm"
      if qs.created?
        qs.memo_state = 1
        qs.set_memo_state_ex(1, 0)
        qs.start_quest
        html = event
      end
    when "30834-04.htm"
      if pc.in_category?(CategoryType::WIZARD_GROUP) && pc.level >= MIN_LEVEL
        html = event
      end
    when "30834-08.html"
      if has_quest_items?(pc, NEBULITE_ORB)
        give_adena(pc, get_quest_items_count(pc, NEBULITE_ORB) * 120, true)
        take_items(pc, NEBULITE_ORB, -1)
        html = event
      else
        html = "30834-08a.html"
      end
    when "30834-11.html"
      qs.exit_quest(true, true)
      html = event
    when "30835-02.html"
      if !has_quest_items?(pc, ECTOPLASM_LIQUEUR)
        html = event
      else
        chance = rand(1000)

        if chance <= 119
          give_items(pc, SCROLL_ENCHANT_WEAPON_D_GRADE, 1)
        elsif chance <= 169
          give_items(pc, SCROLL_ENCHANT_WEAPON_C_GRADE, 1)
        elsif chance <= 329
          give_items(pc, SPIRITSHOT_C_GRADE, rand(200) + 401)
        elsif chance <= 559
          give_items(pc, SPIRITSHOT_D_GRADE, rand(200) + 401)
        elsif chance <= 561
          give_items(pc, SAGES_BLOOD, 1)
        elsif chance <= 578
          give_items(pc, SQUARE_SHIELD, 1)
        elsif chance <= 579
          give_items(pc, NICKLACE_OF_MAGIC, 1)
        elsif chance <= 581
          give_items(pc, RING_OF_AGES, 1)
        elsif chance <= 582
          give_items(pc, TOWER_SHIELD, 1)
        elsif chance <= 584
          give_items(pc, NICKLACE_OF_MERMAID, 1)
        else
          give_items(pc, SCROLL_OF_ESCAPE, 1)
        end

        take_items(pc, ECTOPLASM_LIQUEUR, 1)
        html = "30835-03.html"
      end
    when "30934-05.html"
      if qs.memo_state?(1)
        if qs.get_memo_state_ex(1) >= 25
          html = event
        elsif qs.get_memo_state_ex(1) >= 1 && qs.get_memo_state_ex(1) < 25 && get_quest_items_count(pc, NEBULITE_ORB) < 10
          html = "30934-06.html"
        elsif qs.get_memo_state_ex(1) >= 1 && qs.get_memo_state_ex(1) < 25 && get_quest_items_count(pc, NEBULITE_ORB) > 10
          qs.memo_state = 2
          take_items(pc, NEBULITE_ORB, 10)
          html = "30934-07.html"
        end
      end
    when "30934-08a.html"
      if qs.memo_state?(2)
        i0 = rand(100)
        i1 = rand(3)

        if i0 < 20 && i1 == 0
          qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 4)
          qs.set("param1", 0)
          html = event
        elsif i0 < 20 && i1 == 1
          qs.set("param1", 1)
          html = "30934-08b.html"
        elsif i0 < 20 && i1 == 2
          qs.set("param1", 2)
          html = "30934-08c.html"
        elsif i0 >= 20 && i0 < 50 && i1 == 0
          if rand(2) == 0
            qs.set("param1", 0)
          else
            qs.set("param1", 1)
          end
          html = "30934-09a.html"
        elsif i0 >= 20 && i0 < 50 && i1 == 1
          if rand(2) == 0
            qs.set("param1", 1)
          else
            qs.set("param1", 2)
          end
          html = "30934-09b.html"
        elsif i0 >= 20 && i0 < 50 && i1 == 2
          if rand(2) == 0
            qs.set("param1", 2)
          else
            qs.set("param1", 0)
          end
          html = "30934-09c.html"
        else
          qs.set("param1", rand(3))
          html = "30934-10.html"
        end
      end
    when "30934-11a.html"
      if qs.memo_state?(2)
        if qs.get_int("param1") == 0
          give_items(pc, NEBULITE_ORB, 10)
          qs.set("param1", 4)
          html = event
        elsif qs.get_int("param1") == 1
          html = "30934-11b.html"
        elsif qs.get_int("param1") == 2
          give_items(pc, NEBULITE_ORB, 20)
          qs.set("param1", 4)
          html = "30934-11c.html"
        end
        qs.memo_state = 1
      end
    when "30934-12a.html"
      if qs.memo_state?(2)
        if qs.get_int("param1") == 0
          give_items(pc, NEBULITE_ORB, 20)
          qs.set("param1", 4)
          html = event
        elsif qs.get_int("param1") == 1
          give_items(pc, NEBULITE_ORB, 10)
          qs.set("param1", 4)
          html = "30934-12b.html"
        elsif qs.get_int("param1") == 2
          html = "30934-12c.html"
        end
        qs.memo_state = 1
      end
    when "30934-13a.html"
      if qs.memo_state?(2)
        if qs.get_int("param1") == 0
          html = event
        elsif qs.get_int("param1") == 1
          give_items(pc, NEBULITE_ORB, 20)
          qs.set("param1", 4)
          html = "30934-13b.html"
        elsif qs.get_int("param1") == 2
          give_items(pc, NEBULITE_ORB, 10)
          qs.set("param1", 4)
          html = "30934-13c.html"
        end
        qs.memo_state = 1
      end
    when "30935-03.html"
      if get_quest_items_count(pc, NEBULITE_ORB) < 10
        html = event
      else
        qs.set("param2", rand(2))
        html = "30935-04.html"
      end
    when "30935-05.html"
      if qs.get_int("param1") == 0 && qs.get_int("param2") == 0 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 1)
        qs.set("param2", 2)
        html = event
      elsif qs.get_int("param1") == 1 && qs.get_int("param2") == 0 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 2)
        qs.set("param2", 2)
        html = "30935-05a.html"
      elsif qs.get_int("param1") == 2 && qs.get_int("param2") == 0 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 3)
        qs.set("param2", 2)
        html = "30935-05b.html"
      elsif qs.get_int("param1") == 3 && qs.get_int("param2") == 0 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 4)
        qs.set("param2", 2)
        html = "30935-05c.html"
      elsif qs.get_int("param1") == 4 && qs.get_int("param2") == 0 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 0)
        qs.set("param2", 2)
        give_items(pc, NEBULITE_ORB, 310)
        html = "30935-05d.html"
      elsif qs.get_int("param2") == 1 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        take_items(pc, NEBULITE_ORB, 10)
        qs.set("param1", 0)
        qs.set("param2", 2)
        html = "30935-06.html"
      elsif qs.get_quest_items_count(NEBULITE_ORB) < 10
        html = "30935-03.html"
      end
    when "30935-07.html"
      if qs.get_int("param2") == 0 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        take_items(pc, NEBULITE_ORB, 10)
        qs.set("param1", 0)
        qs.set("param2", 2)
        html = event
      elsif qs.get_int("param1") == 0 && qs.get_int("param2") == 1 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 1)
        qs.set("param2", 2)
        html = "30935-08.html"
      elsif qs.get_int("param1") == 1 && qs.get_int("param2") == 1 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 2)
        qs.set("param2", 2)
        html = "30935-08a.html"
      elsif qs.get_int("param1") == 2 && qs.get_int("param2") == 1 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 3)
        qs.set("param2", 2)
        html = "30935-08b.html"
      elsif qs.get_int("param1") == 3 && qs.get_int("param2") == 1 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 4)
        qs.set("param2", 2)
        html = "30935-08c.html"
      elsif qs.get_int("param1") == 4 && qs.get_int("param2") == 1 && qs.get_quest_items_count(NEBULITE_ORB) >= 10
        qs.set("param1", 0)
        qs.set("param2", 2)
        give_items(pc, NEBULITE_ORB, 310)
        html = "30935-08d.html"
      elsif qs.get_quest_items_count(NEBULITE_ORB) < 10
        html = "30935-03.html"
      end
    when "30935-09.html"
      if qs.get_int("param1") == 1
        qs.set("param1", 0)
        qs.set("param2", 2)
        give_items(pc, NEBULITE_ORB, 10)
        html = event
      elsif qs.get_int("param1") == 2
        qs.set("param1", 0)
        qs.set("param2", 2)
        give_items(pc, NEBULITE_ORB, 30)
        html = "30935-09a.html"
      elsif qs.get_int("param1") == 3
        qs.set("param1", 0)
        qs.set("param2", 2)
        give_items(pc, NEBULITE_ORB, 70)
        html = "30935-09b.html"
      elsif qs.get_int("param1") == 4
        qs.set("param1", 0)
        qs.set("param2", 2)
        give_items(pc, NEBULITE_ORB, 150)
        html = "30935-09c.html"
      end
    when "30935-10.html"
      qs.set("param1", 0)
      qs.set("param2", 2)
      html = event
    when "30834-04a.html", "30834-06a.html", "30834-09a.html", "30834-09b.html",
         "30834-11a.html", "30834-09.html", "30834-10.html", "30835-04.html",
         "30835-05.html", "30934-03a.html", "30935-01.html", "30935-01a.html",
         "30935-01b.html"
      html = event
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when MANASHEN_GARGOYLE, ENCHANTED_MONSTEREYE
        if rand(100) < 63
          give_items(killer, NEBULITE_ORB, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        end

        if qs.get_memo_state_ex(1) > 1
          if rand(100) <= 12
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) - 1)
          end
        end
      when ENCHANTED_STONE_GOLEM
        if rand(100) < 65
          give_items(killer, NEBULITE_ORB, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        end

        if qs.get_memo_state_ex(1) > 1
          if rand(100) <= 12
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) - 1)
          end
        end
      when ENCHANTED_IRON_GOLEM
        if rand(100) < 68
          give_items(killer, NEBULITE_ORB, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        end

        if qs.get_memo_state_ex(1) > 1
          if rand(100) <= 13
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) - 1)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == MAGIC_TRADER_CEMA
        if pc.in_category?(CategoryType::WIZARD_GROUP)
          if pc.level >= MIN_LEVEL
            html = "30834-03.htm"
          else
            html = "30834-02.htm"
          end
        else
          html = "30834-01.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when MAGIC_TRADER_CEMA
        if !has_quest_items?(pc, NEBULITE_ORB)
          html = "30834-06.html"
        else
          html = "30834-07.html"
        end
      when LICH_KING_ICARUS
        html = "30835-01.html"
      when COLLECTOR_MARSHA
        if qs.get_memo_state_ex(1) == 0
          qs.set_memo_state_ex(1, 1)
          html = "30934-03.html"
        else
          qs.memo_state = 1
          html = "30934-04.html"
        end
      when COLLECTOR_TRUMPIN
        qs.set("param1", 0)
        html = "30935-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
