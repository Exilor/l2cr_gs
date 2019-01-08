class Quests::Q00420_LittleWing < Quest
  # NPCs
  private MARIA = 30608
  private CRONOS = 30610
  private BYRON = 30711
  private MIMYU = 30747
  private EXARION = 30748
  private ZWOV = 30749
  private KALIBRAN = 30750
  private SUZET = 30751
  private SHAMHAI = 30752
  private COOPER = 30829
  # Items
  private COAL = 1870
  private CHARCOAL = 1871
  private SILVER_NUGGET = 1873
  private STONE_OF_PURITY = 1875
  private GEMSTONE_D = 2130
  private GEMSTONE_C = 2131
  private FAIRY_DUST = 3499
  private FAIRY_STONE = 3816
  private DELUXE_FAIRY_STONE = 3817
  private FAIRY_STONE_LIST = 3818
  private DELUXE_STONE_LIST = 3819
  private TOAD_SKIN = 3820
  private MONKSHOOD_JUICE = 3821
  private EXARION_SCALE = 3822
  private EXARION_EGG = 3823
  private ZWOV_SCALE = 3824
  private ZWOV_EGG = 3825
  private KALIBRAN_SCALE = 3826
  private KALIBRAN_EGG = 3827
  private SUZET_SCALE = 3828
  private SUZET_EGG = 3829
  private SHAMHAI_SCALE = 3830
  private SHAMHAI_EGG = 3831
  # Monsters
  private DEAD_SEEKER = 20202
  private TOAD_LORD = 20231
  private MARSH_SPIDER = 20233
  private BREKA_OVERLORD = 20270
  private ROAD_SCAVENGER = 20551
  private LETO_WARRIOR = 20580
  DELUXE_STONE_BREAKERS = {
    20589, # Fline
    20590, # Liele
    20591, # Valley Treant
    20592, # Satyr
    20593, # Unicorn
    20594, # Forest Runner
    20595, # Fline Elder
    20596, # Liele Elder
    20597, # Valley Treant Elder
    20598, # Satyr Elder
    20599, # Unicorn Elder
    27185, # Fairy Tree of Wind (Quest Monster)
    27186, # Fairy Tree of Star (Quest Monster)
    27187, # Fairy Tree of Twilight (Quest Monster)
    27188, # Fairy Tree of Abyss (Quest Monster)
    27189  # Soul of Tree Guardian (Quest Monster)
  }
  # Rewards
  private DRAGONFLUTE_OF_WIND = 3500
  private DRAGONFLUTE_OF_STAR = 3501
  private DRAGONFLUTE_OF_TWILIGHT = 3502
  private HATCHLING_ARMOR = 3912
  private HATCHLING_FOOD = 4038
  private EGGS = {EXARION_EGG, SUZET_EGG, KALIBRAN_EGG, SHAMHAI_EGG, ZWOV_EGG}
  # Drake Drops
  private EGG_DROPS = {
    DEAD_SEEKER => SHAMHAI_EGG,
    MARSH_SPIDER => ZWOV_EGG,
    BREKA_OVERLORD => SUZET_EGG,
    ROAD_SCAVENGER => KALIBRAN_EGG,
    LETO_WARRIOR => EXARION_EGG,
  }
  # Misc
  private MIN_LVL = 35

  def initialize
    super(420, self.class.simple_name, "Little Wing")

    add_start_npc(COOPER)
    add_talk_id(
      MARIA, CRONOS, BYRON, MIMYU, EXARION, ZWOV, KALIBRAN, SUZET, SHAMHAI,
      COOPER
    )
    add_attack_id(DELUXE_STONE_BREAKERS)
    add_kill_id(
      TOAD_LORD, DEAD_SEEKER, MARSH_SPIDER, BREKA_OVERLORD, ROAD_SCAVENGER,
      LETO_WARRIOR
    )
    register_quest_items(
      FAIRY_DUST, FAIRY_STONE, DELUXE_FAIRY_STONE, FAIRY_STONE_LIST,
      DELUXE_STONE_LIST, TOAD_SKIN, MONKSHOOD_JUICE, EXARION_SCALE,
      EXARION_EGG, ZWOV_SCALE, ZWOV_EGG, KALIBRAN_SCALE, KALIBRAN_EGG,
      SUZET_SCALE, SUZET_EGG, SHAMHAI_SCALE, SHAMHAI_EGG
    )
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "30610-02.html", "30610-03.html", "30610-04.html", "30711-02.html",
         "30747-05.html", "30747-06.html", "30751-02.html"
      htmltext = event
    when "30829-02.htm"
      if qs.created?
        qs.start_quest
        htmltext = event
      end
    when "30610-05.html"
      if qs.cond?(1)
        qs.set_cond(2, true)
        qs.set("old_stone", 0)
        qs.set("fairy_stone", 1)
        give_items(player, FAIRY_STONE_LIST, 1)
        htmltext = event
      end
    when "30610-06.html"
      if qs.cond?(1)
        qs.set_cond(2, true)
        qs.set("old_stone", 0)
        qs.set("fairy_stone", 2)
        give_items(player, DELUXE_STONE_LIST, 1)
        htmltext = event
      end
    when "30610-12.html"
      if qs.cond?(5)
        qs.set_cond(2, true)
        qs.set("old_stone", qs.get_int("fairy_stone"))
        qs.set("fairy_stone", 1)
        give_items(player, FAIRY_STONE_LIST, 1)
        htmltext = event
      end
    when "30610-13.html"
      if qs.cond?(5)
        qs.set_cond(2, true)
        qs.set("old_stone", qs.get_int("fairy_stone"))
        qs.set("fairy_stone", 2)
        give_items(player, DELUXE_STONE_LIST, 1)
        htmltext = event
      end
    when "30608-03.html"
      if qs.cond?(2)
        if qs.get_int("fairy_stone") == 1
          if get_quest_items_count(player, COAL) >= 10
            if get_quest_items_count(player, CHARCOAL) >= 10
              if get_quest_items_count(player, GEMSTONE_D) >= 1
                if get_quest_items_count(player, SILVER_NUGGET) >= 3
                  if get_quest_items_count(player, TOAD_SKIN) >= 10
                    take_items(player, FAIRY_STONE_LIST, -1)
                    take_items(player, COAL, 10)
                    take_items(player, CHARCOAL, 10)
                    take_items(player, GEMSTONE_D, 1)
                    take_items(player, SILVER_NUGGET, 3)
                    take_items(player, TOAD_SKIN, -1)
                    give_items(player, FAIRY_STONE, 1)
                  end
                end
              end
            end
          end
        end
        qs.set_cond(3, true)
        htmltext = event
      end
    when "30608-05.html"
      if qs.cond?(2)
        if qs.get_int("fairy_stone") == 2
          if get_quest_items_count(player, COAL) >= 10
            if get_quest_items_count(player, CHARCOAL) >= 10
              if get_quest_items_count(player, GEMSTONE_C) >= 1
                if get_quest_items_count(player, STONE_OF_PURITY) >= 1
                  if get_quest_items_count(player, SILVER_NUGGET) >= 5
                    if get_quest_items_count(player, TOAD_SKIN) >= 20
                      take_items(player, DELUXE_STONE_LIST, -1)
                      take_items(player, COAL, 10)
                      take_items(player, CHARCOAL, 10)
                      take_items(player, GEMSTONE_C, 1)
                      take_items(player, STONE_OF_PURITY, 1)
                      take_items(player, SILVER_NUGGET, 5)
                      take_items(player, TOAD_SKIN, -1)
                      give_items(player, DELUXE_FAIRY_STONE, 1)
                    end
                  end
                end
              end
            end
          end
        end
        qs.set_cond(3, true)
        htmltext = event
      end
    when "30711-03.html"
      if qs.cond?(3)
        qs.set_cond(4, true)
        if qs.get_int("fairy_stone") == 2
          htmltext = "30711-04.html"
        else
          htmltext = event
        end
      end
    when "30747-02.html", "30747-04.html"
      if qs.cond?(4) && ((get_quest_items_count(player, FAIRY_STONE) + get_quest_items_count(player, DELUXE_FAIRY_STONE)) > 0)
        take_items(player, -1, {FAIRY_STONE, DELUXE_FAIRY_STONE})
        if qs.get_int("fairy_stone") == 2
          give_items(player, FAIRY_DUST, 1)
        end
        qs.set_cond(5, true)
        htmltext = event
      end
    when "30747-07.html", "30747-08.html"
      if qs.cond?(5) && get_quest_items_count(player, MONKSHOOD_JUICE) == 0
        give_items(player, MONKSHOOD_JUICE, 1)
        htmltext = event
      end
    when "30747-12.html"
      if qs.cond?(7)
        if qs.get_int("fairy_stone") == 1 || get_quest_items_count(player, FAIRY_DUST) == 0
          give_reward(player)
          qs.exit_quest(true, true)
          htmltext = "30747-16.html"
        else
          qs.set_cond(8, false)
          htmltext = event
        end
      elsif qs.cond?(8)
        htmltext = event
      end
    when "30747-13.html"
      if qs.cond?(8)
        give_reward(player)
        qs.exit_quest(true, true)
        htmltext = event
      end
    when "30747-15.html"
      if qs.cond?(8) && get_quest_items_count(player, FAIRY_DUST) > 1
        if Rnd.rand(100) < 5
          give_items(player, HATCHLING_ARMOR, 1)
          htmltext = "30747-14.html"
        else
          give_items(player, HATCHLING_FOOD, 20)
          htmltext = event
        end
        give_reward(player)
        take_items(player, FAIRY_DUST, -1)
        qs.exit_quest(true, true)
      end
    when "30748-02.html"
      if qs.cond?(5)
        take_items(player, MONKSHOOD_JUICE, -1)
        give_items(player, EXARION_SCALE, 1)
        qs.set_cond(6, true)
        qs.set("drake_hunt", LETO_WARRIOR)
        htmltext = event
      end
    when "30749-02.html"
      if qs.cond?(5)
        take_items(player, MONKSHOOD_JUICE, -1)
        give_items(player, ZWOV_SCALE, 1)
        qs.set_cond(6, true)
        qs.set("drake_hunt", MARSH_SPIDER)
        htmltext = event
      end
    when "30750-02.html"
      if qs.cond?(5)
        take_items(player, MONKSHOOD_JUICE, -1)
        give_items(player, KALIBRAN_SCALE, 1)
        qs.set_cond(6, true)
        qs.set("drake_hunt", ROAD_SCAVENGER)
        htmltext = event
      end
    when "30750-05.html"
      if qs.cond?(6) && get_quest_items_count(player, KALIBRAN_EGG) >= 20
        take_items(player, -1, {KALIBRAN_SCALE, KALIBRAN_EGG})
        give_items(player, KALIBRAN_EGG, 1)
        qs.set_cond(7, true)
        htmltext = event
      end
    when "30751-03.html"
      if qs.cond?(5)
        take_items(player, MONKSHOOD_JUICE, -1)
        give_items(player, SUZET_SCALE, 1)
        qs.set_cond(6, true)
        qs.set("drake_hunt", BREKA_OVERLORD)
        htmltext = event
      end
    when "30752-02.html"
      if qs.cond?(5)
        take_items(player, MONKSHOOD_JUICE, -1)
        give_items(player, SHAMHAI_SCALE, 1)
        qs.set_cond(6, true)
        qs.set("drake_hunt", DEAD_SEEKER)
        htmltext = event
      end
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon)
    return super unless qs = get_quest_state(attacker, false)
    if get_quest_items_count(attacker, DELUXE_FAIRY_STONE) > 0 && Rnd.rand(100) < 30
      take_items(attacker, DELUXE_FAIRY_STONE, -1)
      qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_STONE_THE_ELVEN_STONE_BROKE))
    end

    super
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)
    htmltext = get_no_quest_msg(talker)

    case qs.state
    when State::CREATED
      if npc.id == COOPER
        htmltext = talker.level >= MIN_LVL ? "30829-01.htm" : "30829-03.html"
      end
    when State::STARTED
      case npc.id
      when COOPER
        htmltext = "30829-04.html"
      when CRONOS
        case qs.cond
        when 1
          htmltext = "30610-01.html"
        when 2
          htmltext = "30610-07.html"
        when 3
          if qs.get_int("old_stone") > 0
            htmltext = "30610-14.html"
          else
            htmltext = "30610-08.html"
          end
        when 4
          htmltext = "30610-09.html"
        when 5
          if get_quest_items_count(talker, FAIRY_STONE) == 0 && get_quest_items_count(talker, DELUXE_FAIRY_STONE) == 0
            htmltext = "30610-10.html"
          else
            htmltext = "30610-11.html"
          end
        end
      when MARIA
        case qs.cond
        when 2
          if qs.get_int("fairy_stone") == 1 && get_quest_items_count(talker, COAL) >= 10 && get_quest_items_count(talker, CHARCOAL) >= 10 && get_quest_items_count(talker, GEMSTONE_D) >= 1 && get_quest_items_count(talker, SILVER_NUGGET) >= 3 && get_quest_items_count(talker, TOAD_SKIN) >= 10
            htmltext = "30608-02.html"
          elsif qs.get_int("fairy_stone") == 2 && get_quest_items_count(talker, COAL) >= 10 && get_quest_items_count(talker, CHARCOAL) >= 10 && get_quest_items_count(talker, GEMSTONE_C) >= 1 && get_quest_items_count(talker, STONE_OF_PURITY) >= 1 && get_quest_items_count(talker, SILVER_NUGGET) >= 5 && get_quest_items_count(talker, TOAD_SKIN) >= 20
            htmltext = "30608-04.html"
          else
            htmltext = "30608-01.html"
          end
        when 3
          htmltext = "30608-06.html"
        end
      when BYRON
        case qs.cond
        when 2
          htmltext = "30711-10.html"
        when 3
          if qs.get_int("old_stone") == 0
            htmltext = "30711-01.html"
          elsif qs.get_int("old_stone") == 1
            qs.set_cond(5, true)
            htmltext = "30711-05.html"
          else
            qs.set_cond(4, true)
            htmltext = "30711-06.html"
          end
        when 4
          if get_quest_items_count(talker, FAIRY_STONE) == 0 && get_quest_items_count(talker, DELUXE_FAIRY_STONE) == 0
            htmltext = "30711-09.html"
          elsif get_quest_items_count(talker, FAIRY_STONE) == 0
            htmltext = "30711-08.html"
          else
            htmltext = "30711-07.html"
          end
        end
      when MIMYU
        case qs.cond
        when 4
          if get_quest_items_count(talker, FAIRY_STONE) > 0
            htmltext = "30747-01.html"
          elsif get_quest_items_count(talker, DELUXE_FAIRY_STONE) > 0
            htmltext = "30747-03.html"
          end
        when 5
          if get_quest_items_count(talker, MONKSHOOD_JUICE) > 0
            htmltext = "30747-09.html"
          elsif qs.get_int("fairy_stone") == 1
            htmltext = "30747-05.html"
          else
            htmltext = "30747-06.html"
          end
        when 6
          if get_quest_items_count(talker, EXARION_EGG) >= 20 || get_quest_items_count(talker, ZWOV_EGG) >= 20 || get_quest_items_count(talker, KALIBRAN_EGG) >= 20 || get_quest_items_count(talker, SUZET_EGG) >= 20 || get_quest_items_count(talker, SHAMHAI_EGG) >= 20
            htmltext = "30747-10.html"
          else
            htmltext = "30747-09.html"
          end
        when 7
          htmltext = "30747-11.html"
        when 8
          htmltext = "30747-12.html"
        end
      when EXARION
        case qs.cond
        when 5
          if get_quest_items_count(talker, MONKSHOOD_JUICE) > 0
            htmltext = "30748-01.html"
          end
        when 6
          if get_quest_items_count(talker, EXARION_EGG) >= 20
            take_items(talker, -1, {EXARION_SCALE, EXARION_EGG})
            give_items(talker, EXARION_EGG, 1)
            qs.set_cond(7, true)
            htmltext = "30748-04.html"
          else
            htmltext = "30748-03.html"
          end
        when 7
          htmltext = "30748-05.html"
        end
      when ZWOV
        case qs.cond
        when 5
          if get_quest_items_count(talker, MONKSHOOD_JUICE) > 0
            htmltext = "30749-01.html"
          end
        when 6
          if get_quest_items_count(talker, ZWOV_EGG) >= 20
            take_items(talker, -1, {ZWOV_SCALE, ZWOV_EGG})
            give_items(talker, ZWOV_EGG, 1)
            qs.set_cond(7, true)
            htmltext = "30749-04.html"
          else
            htmltext = "30749-03.html"
          end
        when 7
          htmltext = "30749-05.html"
        end
      when KALIBRAN
        case qs.cond
        when 5
          if get_quest_items_count(talker, MONKSHOOD_JUICE) > 0
            htmltext = "30750-01.html"
          end
        when 6
          if get_quest_items_count(talker, KALIBRAN_EGG) >= 20
            htmltext = "30750-04.html"
          else
            htmltext = "30750-03.html"
          end
        when 7
          htmltext = "30750-06.html"
        end
      when SUZET
        case qs.cond
        when 5
          if get_quest_items_count(talker, MONKSHOOD_JUICE) > 0
            htmltext = "30751-01.html"
          end
        when 6
          if get_quest_items_count(talker, SUZET_EGG) >= 20
            take_items(talker, -1, {SUZET_SCALE, SUZET_EGG})
            give_items(talker, SUZET_EGG, 1)
            qs.set_cond(7, true)
            htmltext = "30751-05.html"
          else
            htmltext = "30751-04.html"
          end
        when 7
          htmltext = "30751-06.html"
        end
      when SHAMHAI
        case qs.cond
        when 5
          if get_quest_items_count(talker, MONKSHOOD_JUICE) > 0
            htmltext = "30752-01.html"
          end
        when 6
          if get_quest_items_count(talker, SHAMHAI_EGG) >= 20
            take_items(talker, -1, {SHAMHAI_SCALE, SHAMHAI_EGG})
            give_items(talker, SHAMHAI_EGG, 1)
            qs.set_cond(7, true)
            htmltext = "30752-04.html"
          else
            htmltext = "30752-03.html"
          end
        when 7
          htmltext = "30752-05.html"
        end
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(talker)
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, -1, 3, npc)
    if qs
      if qs.cond?(2) && npc.id == TOAD_LORD
        if qs.get_int("fairy_stone") == 1
          give_item_randomly(qs.player, npc, TOAD_SKIN, 1, 10, 0.3, true)
        else
          give_item_randomly(qs.player, npc, TOAD_SKIN, 1, 20, 0.3, true)
        end
      elsif qs.cond?(6) && npc.id == qs.get_int("drake_hunt")
        give_item_randomly(qs.player, npc, EGG_DROPS[npc.id], 1, 20, 0.5, true)
      end
    end

    super
  end

  private def give_reward(player)
    random = Rnd.rand(100)
    EGGS.each_with_index do |i, j|
      if has_quest_items?(player, i)
        mul = j * 5
        if has_quest_items?(player, FAIRY_DUST)
          if random < (45 + mul)
            give_items(player, DRAGONFLUTE_OF_WIND, 1)
          elsif random < (75 + mul)
            give_items(player, DRAGONFLUTE_OF_STAR, 1)
          else
            give_items(player, DRAGONFLUTE_OF_TWILIGHT, 1)
          end
        end

        if random < (50 + mul)
          give_items(player, DRAGONFLUTE_OF_WIND, 1)
        elsif random < (85 + mul)
          give_items(player, DRAGONFLUTE_OF_STAR, 1)
        else
          give_items(player, DRAGONFLUTE_OF_TWILIGHT, 1)
        end
        take_items(player, i, -1)
      end
    end
  end
end
