class Scripts::Q00386_StolenDignity < Quest
  # NPCs
  private WAREHOUSE_KEEPER_ROMP = 30843

  # Monsters
  private CRIMSON_DRAKE = 20670
  private KADIOS = 20671
  private HUNGRY_CORPSE = 20954
  private PAST_KNIGHT = 20956
  private BLADE_DEATH = 20958
  private DARK_GUARD = 20959
  private BLOODY_GHOST = 20960
  private BLOODY_LORD = 20963
  private PAST_CREATURE = 20967
  private GIANT_SHADOW = 20969
  private ANCIENTS_SOLDIER = 20970
  private ANCIENTS_WARRIOR = 20971
  private SPITE_SOUL_LEADER = 20974
  private SPITE_SOUL_WIZARD = 20975
  private WRECKED_ARCHER = 21001
  private FLOAT_OF_GRAVE = 21003
  private GRAVE_PREDATOR = 21005
  private FALLEN_ORC_SHAMAN = 21020
  private SHARP_TALON_TIGER = 21021
  private GLOW_WISP = 21108
  private MARSH_PREDATOR = 21110
  private HAMES_ORC_SNIPER = 21113
  private CURSED_GUARDIAN = 21114
  private HAMES_ORC_CHIEFTAIN = 21116
  private FALLEN_ORC_SHAMAN_TRANS = 21258
  private SHARP_TALON_TIGER_TRANS = 21259
  # Items
  private Q_STOLEN_INF_ORE = 6363
  # Reward
  private DRAGON_SLAYER_EDGE = 5529
  private METEOR_SHOWER_HEAD = 5532
  private ELYSIAN_HEAD = 5533
  private SOUL_BOW_SHAFT = 5534
  private CARNIUM_BOW_SHAFT = 5535
  private BLOODY_ORCHID_HEAD = 5536
  private SOUL_SEPARATOR_HEAD = 5537
  private DRAGON_GRINDER_EDGE = 5538
  private BLOOD_TORNADO_EDGE = 5539
  private TALLUM_GLAIVE_EDGE = 5541
  private HALBARD_EDGE = 5542
  private DASPARIONS_STAFF_HEAD = 5543
  private WORLDTREES_BRANCH_HEAD = 5544
  private DARK_LEGIONS_EDGE_EDGE = 5545
  private SWORD_OF_MIRACLE_EDGE = 5546
  private ELEMENTAL_SWORD_EDGE = 5547
  private TALLUM_BLADE_EDGE = 5548
  private INFERNO_MASTER_BLADE = 8331
  private EYE_OF_SOUL_PIECE = 8341
  private DRAGON_FLAME_HEAD_PIECE = 8342
  private DOOM_CRUSHER_HEAD = 8349
  private HAMMER_OF_DESTROYER_PIECE = 8346
  private SIRR_BLADE_BLADE = 8712
  private SWORD_OF_IPOS_BLADE = 8713
  private BARAKIEL_AXE_PIECE = 8714
  private TUNING_FORK_OF_BEHEMOTH_PIECE = 8715
  private NAGA_STORM_PIECE = 8716
  private TIPHON_SPEAR_EDGE = 8717
  private SHYID_BOW_SHAFT = 8718
  private SOBEKK_HURRICANE_EDGE = 8719
  private TONGUE_OF_THEMIS_PIECE = 8720
  private HAND_OF_CABRIO_HEAD = 8721
  private CRYSTAL_OF_DEAMON_PIECE = 8722

  def initialize
    super(386, self.class.simple_name, "Stolen Dignity")

    add_start_npc(WAREHOUSE_KEEPER_ROMP)
    add_talk_id(WAREHOUSE_KEEPER_ROMP)
    add_kill_id(
      CRIMSON_DRAKE, KADIOS, HUNGRY_CORPSE, PAST_KNIGHT, BLADE_DEATH,
      DARK_GUARD, BLOODY_GHOST, BLOODY_LORD, PAST_CREATURE, GIANT_SHADOW,
      ANCIENTS_SOLDIER, ANCIENTS_WARRIOR, SPITE_SOUL_LEADER, SPITE_SOUL_WIZARD,
      WRECKED_ARCHER, FLOAT_OF_GRAVE, GRAVE_PREDATOR, FALLEN_ORC_SHAMAN,
      SHARP_TALON_TIGER, GLOW_WISP, MARSH_PREDATOR, HAMES_ORC_SNIPER,
      CURSED_GUARDIAN, HAMES_ORC_CHIEFTAIN, FALLEN_ORC_SHAMAN_TRANS,
      SHARP_TALON_TIGER_TRANS
    )
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if npc.id == WAREHOUSE_KEEPER_ROMP
      if qs.created?
        if pc.level >= 58
          return "30843-01.htm"
        end
        return "30843-04.html"
      end
      if qs.get_quest_items_count(Q_STOLEN_INF_ORE) < 100
        return "30843-06.html"
      end
      return "30843-07.html"
    end

    get_no_quest_msg(pc)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc

    qs = get_quest_state(pc, false)
    if qs && npc.id == WAREHOUSE_KEEPER_ROMP
      if event == "QUEST_ACCEPTED"
        qs.play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
        qs.memo_state = 386
        qs.start_quest
        qs.show_question_mark(386) # and what does this accomplish?
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30843-05.htm"
      end
      if event.includes?(".html")
        return event
      end
      ask = event.to_i
      case ask
      when 3
        return "30843-09a.htm" # It was .html in L2J
      when 5
        return "30843-03.html"
      when 6
        qs.exit_quest(true)
        return "30843-08.html"
      when 9
        return "30843-09.html" # It was .htm in L2J
      when 8
        if qs.get_quest_items_count(Q_STOLEN_INF_ORE) >= 100
          qs.take_items(Q_STOLEN_INF_ORE, 100)
          create_bingo_board(qs)
          return "30843-12.html"
        end
        return "30843-11.html"
      when 10..18
        select_bingo_number(qs, ask - 9)
        return fill_board(pc, qs, get_htm(pc, "30843-13.html"))
      when 19..27
        return take_html(pc, qs, ask - 18)
      when 55..63
        return before_reward(pc, qs, ask - 54)
      end

    end

    super
  end

  private def take_html(pc, qs, num) : String
    html = ""
    if !selected_bingo_number?(qs, num)
      select_bingo_number(qs, num)
      i3 = get_bingo_select_count(qs)

      if i3 == 2
        html = get_htm(pc, "30843-14.html")
      elsif i3 == 3
        html = get_htm(pc, "30843-16.html")
      elsif i3 == 4
        html = get_htm(pc, "30843-18.html")
      elsif i3 == 5
        html = get_htm(pc, "30843-20.html")
      end
      return fill_board(pc, qs, html)
    end
    i3 = get_bingo_select_count(qs)
    if i3 == 1
      html = get_htm(pc, "30843-15.html")
    elsif i3 == 2
      html = get_htm(pc, "30843-17.html")
    elsif i3 == 3
      html = get_htm(pc, "30843-19.html")
    elsif i3 == 4
      html = get_htm(pc, "30843-21.html")
    end

    fill_board(pc, qs, html)
  end

  private def fill_board(pc, qs, html : String) : String
    9.times do |i0|
      i1 = get_number_from_bingo_board(qs, i0)
      if selected_bingo_number?(qs, i1)
        html = html.sub("<?Cell#{i0 + 1}?>", i1.to_s)
      else
        html = html.sub("<?Cell#{i0 + 1}?>", "?")
      end
    end

    html.not_nil!
  end

  private def color_board(pc, qs, html : String) : String
    9.times do |i0|
      i1 = get_number_from_bingo_board(qs, i0)
      if selected_bingo_number?(qs, i1)
        html = html.sub("<?FontColor#{i0 + 1}?>", "ff0000")
      else
        html = html.sub("<?FontColor#{i0 + 1}?>", "ffffff")
      end
      html = html.sub("<?Cell#{i0 + 1}?>", i1.to_s)
    end

    html.not_nil!
  end

  private def before_reward(pc, qs, num)
    unless selected_bingo_number?(qs, num)
      select_bingo_number(qs, num)
      i3 = get_matched_bingo_line_count(qs)
      if i3 == 3 && get_bingo_select_count(qs) == 6
        reward(pc, qs, 4)
        html = get_htm(pc, "30843-22.html")
      elsif i3 == 0 && get_bingo_select_count(qs) == 6
        reward(pc, qs, 10)
        html = get_htm(pc, "30843-24.html")
      else
        html = get_htm(pc, "30843-23.html")
      end
      return color_board(pc, qs, html)
    end

    fill_board(pc, qs, get_htm(pc, "30843-25.html"))
  end

  private def reward(pc, qs, count)
    case Rnd.rand(33)
    when 0
      qs.give_items(DRAGON_SLAYER_EDGE, count)
    when 1
      qs.give_items(METEOR_SHOWER_HEAD, count)
    when 2
      qs.give_items(ELYSIAN_HEAD, count)
    when 3
      qs.give_items(SOUL_BOW_SHAFT, count)
    when 4
      qs.give_items(CARNIUM_BOW_SHAFT, count)
    when 5
      qs.give_items(BLOODY_ORCHID_HEAD, count)
    when 6
      qs.give_items(SOUL_SEPARATOR_HEAD, count)
    when 7
      qs.give_items(DRAGON_GRINDER_EDGE, count)
    when 8
      qs.give_items(BLOOD_TORNADO_EDGE, count)
    when 9
      qs.give_items(TALLUM_GLAIVE_EDGE, count)
    when 10
      qs.give_items(HALBARD_EDGE, count)
    when 11
      qs.give_items(DASPARIONS_STAFF_HEAD, count)
    when 12
      qs.give_items(WORLDTREES_BRANCH_HEAD, count)
    when 13
      qs.give_items(DARK_LEGIONS_EDGE_EDGE, count)
    when 14
      qs.give_items(SWORD_OF_MIRACLE_EDGE, count)
    when 15
      qs.give_items(ELEMENTAL_SWORD_EDGE, count)
    when 16
      qs.give_items(TALLUM_BLADE_EDGE, count)
    when 17
      qs.give_items(INFERNO_MASTER_BLADE, count)
    when 18
      qs.give_items(EYE_OF_SOUL_PIECE, count)
    when 19
      qs.give_items(DRAGON_FLAME_HEAD_PIECE, count)
    when 20
      qs.give_items(DOOM_CRUSHER_HEAD, count)
    when 21
      qs.give_items(HAMMER_OF_DESTROYER_PIECE, count)
    when 22
      qs.give_items(SIRR_BLADE_BLADE, count)
    when 23
      qs.give_items(SWORD_OF_IPOS_BLADE, count)
    when 24
      qs.give_items(BARAKIEL_AXE_PIECE, count)
    when 25
      qs.give_items(TUNING_FORK_OF_BEHEMOTH_PIECE, count)
    when 26
      qs.give_items(NAGA_STORM_PIECE, count)
    when 27
      qs.give_items(TIPHON_SPEAR_EDGE, count)
    when 28
      qs.give_items(SHYID_BOW_SHAFT, count)
    when 29
      qs.give_items(SOBEKK_HURRICANE_EDGE, count)
    when 30
      qs.give_items(TONGUE_OF_THEMIS_PIECE, count)
    when 31
      qs.give_items(HAND_OF_CABRIO_HEAD, count)
    when 32
      qs.give_items(CRYSTAL_OF_DEAMON_PIECE, count)
    end

  end

  private def create_bingo_board(qs)
    arr = [1,2,3,4,5,6,7,8,9]
    arr.shuffle!
    qs.set("numbers", arr.to_s.gsub(/[^\d ]/, ""))
    qs.set("selected", "? ? ? ? ? ? ? ? ?")
  end

  private def get_matched_bingo_line_count(qs)
    q = qs.get("selected").not_nil!.split

    found = 0
    # Horizontal
    found += 1 if q[0].number? && q[1].number? && q[2].number?
    found += 1 if q[3].number? && q[4].number? && q[5].number?
    found += 1 if q[6].number? && q[7].number? && q[8].number?
    # Vertical
    found += 1 if q[0].number? && q[3].number? && q[6].number?
    found += 1 if q[1].number? && q[4].number? && q[7].number?
    found += 1 if q[2].number? && q[5].number? && q[8].number?
    # Diagonal
    found += 1 if q[0].number? && q[4].number? && q[8].number?
    found += 1 if q[2].number? && q[4].number? && q[6].number?

    found
  end

  private def select_bingo_number(qs, num)
    numbers = qs.get("numbers").not_nil!.split
    pos = 0
    numbers.each_with_index do |number, i|
      if numbers[i].to_i == num
        pos = i
        break
      end
    end
    selected = qs.get("selected").not_nil!.split
    selected.each_with_index do |sel, i|
      if i == pos
        selected[i] = num.to_s
        next
      end
    end
    result = selected[0]
    1.upto(selected.size - 1) do |i|
      result = "#{result} #{selected[i]}"
    end
    qs.set("selected", result)
  end

  private def selected_bingo_number?(qs, num)
    qs.get("selected").not_nil!.includes?(num.to_s)
  end

  private def get_number_from_bingo_board(qs, num)
    qs.get("numbers").not_nil!.split[num].to_i
  end

  private def get_bingo_select_count(qs)
    current = qs.get("selected").not_nil!
    current.gsub(/\D/, "").size
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_player_from_party(killer, npc)
      case npc.id
      when CRIMSON_DRAKE
        if Rnd.rand(1000) < 20.200001
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when KADIOS
        if Rnd.rand(1000) < 211
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when HUNGRY_CORPSE
        if Rnd.rand(1000) < 184
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when PAST_KNIGHT
        if Rnd.rand(1000) < 216
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when BLADE_DEATH
        if Rnd.rand(100) < 17
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when DARK_GUARD
        if Rnd.rand(1000) < 273
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when BLOODY_GHOST
        if Rnd.rand(1000) < 149
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when BLOODY_LORD
        if Rnd.rand(1000) < 199
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when PAST_CREATURE
        if Rnd.rand(1000) < 257
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when GIANT_SHADOW
        if Rnd.rand(1000) < 205
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when ANCIENTS_SOLDIER
        if Rnd.rand(1000) < 208
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when ANCIENTS_WARRIOR
        if Rnd.rand(1000) < 299
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when SPITE_SOUL_LEADER
        if Rnd.rand(100) < 44
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when SPITE_SOUL_WIZARD
        if Rnd.rand(100) < 39
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when WRECKED_ARCHER
        if Rnd.rand(1000) < 214
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when FLOAT_OF_GRAVE
        if Rnd.rand(1000) < 173
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when GRAVE_PREDATOR
        if Rnd.rand(1000) < 211
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when FALLEN_ORC_SHAMAN
        if Rnd.rand(1000) < 478
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when SHARP_TALON_TIGER
        if Rnd.rand(1000) < 234
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when GLOW_WISP
        if Rnd.rand(1000) < 245
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when MARSH_PREDATOR
        if Rnd.rand(100) < 26
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when HAMES_ORC_SNIPER
        if Rnd.rand(100) < 37
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when CURSED_GUARDIAN
        if Rnd.rand(1000) < 352
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      when HAMES_ORC_CHIEFTAIN, FALLEN_ORC_SHAMAN_TRANS, SHARP_TALON_TIGER_TRANS
        if Rnd.rand(1000) < 487
          give_item_randomly(qs.player, npc, Q_STOLEN_INF_ORE, 1, 0, 1, true)
        end
      end

    end

    super
  end

  private def get_random_player_from_party(pc, npc)
    qs = get_quest_state(pc, false)
    candidates = [] of QuestState

    if qs && qs.started?
      candidates << qs
      candidates << qs
    end

    if party = pc.party
      party.members.each do |m|
        if qss = get_quest_state(m, false)
          if qss.started? && Util.in_range?(1500, npc, m, true)
            candidates << qss
          end
        end
      end
    end

    candidates.sample?(random: Rnd)
  end
end
