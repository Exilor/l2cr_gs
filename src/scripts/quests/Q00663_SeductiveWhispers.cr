class Scripts::Q00663_SeductiveWhispers < Quest
  # NPCs
  private WILBERT = 30846
  # Misc
  private MIN_LEVEL = 50
  # Quest items
  private SPIRIT_BEAD = 8766
  # Rewards
  private SCROLL_ENCHANT_WEAPON_A_GRADE = ItemHolder.new(729, 1)
  private SCROLL_ENCHANT_ARMOR_A_GRADE = ItemHolder.new(730, 2)
  private SCROLL_ENCHANT_WEAPON_B_GRADE = ItemHolder.new(947, 2)
  private SCROLL_ENCHANT_ARMOR_B_GRADE = ItemHolder.new(948, 2)
  private SCROLL_ENCHANT_WEAPON_C_GRADE = ItemHolder.new(951, 1)
  private SCROLL_ENCHANT_WEAPON_D_GRADE = ItemHolder.new(955, 1)
  private RECIPE_GREAT_SWORD_60 = ItemHolder.new(4963, 1)
  private RECIPE_HEAVY_WAR_AXE_60 = ItemHolder.new(4964, 1)
  private RECIPE_SPRITES_STAFF_60 = ItemHolder.new(4965, 1)
  private RECIPE_KESHANBERK_60 = ItemHolder.new(4966, 1)
  private RECIPE_SWORD_OF_VALHALLA_60 = ItemHolder.new(4967, 1)
  private RECIPE_KRIS_60 = ItemHolder.new(4968, 1)
  private RECIPE_HELL_KNIFE_60 = ItemHolder.new(4969, 1)
  private RECIPE_ARTHRO_NAIL_60 = ItemHolder.new(4970, 1)
  private RECIPE_DARK_ELVEN_LONG_BOW_60 = ItemHolder.new(4971, 1)
  private RECIPE_GREAT_AXE_60 = ItemHolder.new(4972, 1)
  private RECIPE_SWORD_OF_DAMASCUS_60 = ItemHolder.new(5000, 1)
  private RECIPE_LANCE_60 = ItemHolder.new(5001, 1)
  private RECIPE_DEADMANS_GLORY_60 = ItemHolder.new(5002, 1)
  private RECIPE_ART_OF_BATTLE_AXE_60 = ItemHolder.new(5003, 1)
  private RECIPE_TAFF_OF_EVIL_SPIRITS_60 = ItemHolder.new(5004, 1)
  private RECIPE_DEMONS_DAGGER_60 = ItemHolder.new(5005, 1)
  private RECIPE_BELLION_CESTUS_60 = ItemHolder.new(5006, 1)
  private RECIPE_BOW_OF_PERIL_60 = ItemHolder.new(5007, 1)
  private GREAT_SWORD_BLADE = ItemHolder.new(4104, 12)
  private GREAT_AXE_HEAD = ItemHolder.new(4113, 12)
  private DARK_ELVEN_LONGBOW_SHAFT = ItemHolder.new(4112, 12)
  private SWORD_OF_VALHALLA_BLADE = ItemHolder.new(4108, 12)
  private ARTHRO_NAIL_BLADE = ItemHolder.new(4111, 12)
  private SPRITES_STAFF_HEAD = ItemHolder.new(4104, 12)
  private KRIS_EDGE = ItemHolder.new(4109, 12)
  private KESHANBERK_BLADE = ItemHolder.new(4107, 12)
  private HEAVY_WAR_AXE_HEAD = ItemHolder.new(4105, 12)
  private HELL_KNIFE_EDGE = ItemHolder.new(4110, 12)
  private SWORD_OF_DAMASCUS_BLADE = ItemHolder.new(4114, 13)
  private LANCE_BLADE = ItemHolder.new(4115, 13)
  private BELLION_CESTUS_EDGE = ItemHolder.new(4120, 13)
  private EVIL_SPIRIT_HEAD = ItemHolder.new(4118, 13)
  private DEADMANS_GLORY_STONE = ItemHolder.new(4116, 13)
  private ART_OF_BATTLE_AXE_BLADE = ItemHolder.new(4117, 13)
  private DEMONS_DAGGER_EDGE = ItemHolder.new(4119, 13)
  private BOW_OF_PERIL_SHAFT = ItemHolder.new(4121, 13)
  # Monsters
  private SPITEFUL_SOUL_LEADER = 20974
  private SPITEFUL_SOUL_LEADER_CHANCE = 100
  private MONSTERS = {
    20674 => 807,
    20678 => 372,
    20954 => 460,
    20674 => 537,
    20956 => 540,
    20957 => 565,
    20958 => 425,
    20959 => 682,
    20960 => 372,
    20961 => 547,
    20962 => 522,
    20963 => 498,
    20975 => 975,
    20976 => 825,
    20996 => 385,
    20997 => 342,
    20998 => 377,
    20999 => 450,
    21000 => 395,
    21001 => 535,
    21002 => 472,
    21006 => 502,
    21007 => 540,
    21008 => 692,
    21009 => 740,
    21010 => 595
  }

  def initialize
    super(663, self.class.simple_name, "Seductive Whispers")

    add_start_npc(WILBERT)
    add_talk_id(WILBERT)
    add_kill_id(MONSTERS.keys)
    add_kill_id(SPITEFUL_SOUL_LEADER)
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::CREATED
      html = pc.level < MIN_LEVEL ? "30846-02.html" : "30846-01.htm"
    when State::STARTED
      if qs.memo_state < 4 && qs.memo_state >= 1
        if has_quest_items?(pc, SPIRIT_BEAD)
          html = "30846-05.html"
        else
          html = "30846-04.html"
        end
      end

      if (qs.memo_state // 1000) == 0
        case qs.memo_state % 10
        when 4
          html = "30846-05a.html"
        when 5
          html = "30846-11.html"
        when 6
          html = "30846-15.html"
        when 7
          if (qs.memo_state % 100) // 10 >= 7
            qs.memo_state = 1
            give_adena(pc, 2384000, true)
            give_items(pc, SCROLL_ENCHANT_WEAPON_A_GRADE)
            give_items(pc, SCROLL_ENCHANT_ARMOR_A_GRADE)
            html = "30846-17.html"
          else
            win_count = (qs.memo_state // 10) + 1
            html = get_html(pc, "30846-16.html", 0, 0, win_count, 0)
          end
        end
      elsif qs.memo_state?(1005)
        html = "30846-23.html"
      elsif qs.memo_state?(1006)
        html = "30846-26.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!
    unless qs = get_quest_state(player, false)
      return
    end

    case event
    when "30846-01a.htm"
      if player.level >= MIN_LEVEL
        html = event
      end
    when "30846-03.htm"
      if qs.created? && player.level >= MIN_LEVEL
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "30846-06.html", "30846-07.html", "30846-08.html"
      html = event
    when "30846-09.html"
      if qs.started? && qs.memo_state % 10 <= 4
        memo_state = qs.memo_state // 10
        if memo_state < 1
          if get_quest_items_count(player, SPIRIT_BEAD) >= 50
            take_items(player, SPIRIT_BEAD, 50)
            qs.memo_state = 5
            qs.set_memo_state_ex(1, 0)
            html = event
          else
            html = "30846-10.html"
          end
        else
          qs.memo_state = (memo_state * 10) + 5
          qs.set_memo_state_ex(1, 0)
          html = "30846-09a.html"
        end
      end
    when "30846-14.html"
      if qs.started? && qs.memo_state % 10 == 5 && qs.memo_state // 1000 == 0
        card1pic = Math.max(qs.get_memo_state_ex(1), 0)
        i1 = card1pic % 10
        i2 = (card1pic - i1) // 10
        rnd1 = Rnd.rand(2) + 1
        rnd2 = Rnd.rand(5) + 1
        win_count = (qs.memo_state // 10) + 1
        card2pic = (rnd1 * 10) + rnd2
        if rnd1 == i2
          i3 = rnd2 + i1
          if i3 % 5 == 0 && i3 != 10
            if (qs.memo_state % 100) // 10 >= 7
              give_adena(player, 2384000, true)
              give_items(player, SCROLL_ENCHANT_WEAPON_A_GRADE)
              give_items(player, SCROLL_ENCHANT_ARMOR_A_GRADE)
              qs.memo_state = 4
              html = get_html(player, "30846-14.html", card1pic, card2pic, win_count, -1)
            else
              qs.memo_state = ((qs.memo_state // 10) * 10) + 7
              html = get_html(player, "30846-13.html", card1pic, card2pic, win_count, -1)
            end
          else
            qs.memo_state = ((qs.memo_state // 10) * 10) + 6
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-12.html", card1pic, card2pic, win_count, -1)
          end
        elsif rnd1 != i2
          if rnd2 == 5 || i1 == 5
            if (qs.memo_state % 100) // 10 >= 7
              give_adena(player, 2384000, true)
              give_items(player, SCROLL_ENCHANT_WEAPON_A_GRADE)
              give_items(player, SCROLL_ENCHANT_ARMOR_A_GRADE)
              qs.memo_state = 4
              html = get_html(player, "30846-14.html", card1pic, card2pic, win_count, -1)
            else
              qs.memo_state = ((qs.memo_state // 10) * 10) + 7
              html = get_html(player, "30846-13.html", card1pic, card2pic, win_count, -1)
            end
          else
            qs.memo_state = ((qs.memo_state // 10) * 10) + 6
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-12.html", card1pic, card2pic, win_count, -1)
          end
        end
      end
    when "30846-19.html"
      if qs.started? && qs.memo_state % 10 == 6 && qs.memo_state // 1000 == 0
        card1pic = Math.max(qs.get_memo_state_ex(1), 0)
        i1 = card1pic % 10
        i2 = (card1pic - i1) // 10
        rnd1 = Rnd.rand(2) + 1
        rnd2 = Rnd.rand(5) + 1
        card2pic = (rnd1 * 10) + rnd2
        if rnd1 == i2
          i3 = rnd2 + i1
          if i3 % 5 == 0 && i3 != 10
            qs.memo_state = 1
            qs.set_memo_state_ex(1, 0)
            html = get_html(player, "30846-19.html", card1pic, card2pic, -1, -1)
          else
            qs.memo_state = ((qs.memo_state // 10) * 10) + 5
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-18.html", card1pic, card2pic, -1, -1)
          end
        elsif rnd1 != i2
          if rnd2 == 5 || i1 == 5
            qs.memo_state = 1
            html = get_html(player, "30846-19.html", card1pic, card2pic, -1, -1)
          else
            qs.memo_state = ((qs.memo_state // 10) * 10) + 5
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-18.html", card1pic, card2pic, -1, -1)
          end
        end
      end
    when "30846-20.html"
      if qs.started? && qs.memo_state % 10 == 7 && qs.memo_state // 1000 == 0
        qs.memo_state = (((qs.memo_state // 10) + 1) * 10) + 4
        qs.set_memo_state_ex(1, 0)
        html = event
      end
    when "30846-21.html"
      if qs.started? && qs.memo_state % 10 == 7 && qs.memo_state // 1000 == 0
        i0 = qs.memo_state // 10
        if i0 == 0
          give_adena(player, 40000, true)
        elsif i0 == 1
          give_adena(player, 80000, true)
        elsif i0 == 2
          give_adena(player, 110000, true)
          give_items(player, SCROLL_ENCHANT_WEAPON_D_GRADE, 1)
        elsif i0 == 3
          give_adena(player, 199000, true)
          give_items(player, SCROLL_ENCHANT_WEAPON_C_GRADE, 1)
        elsif i0 == 4
          give_adena(player, 388000, true)
          rnd = Rnd.rand(18) + 1
          if rnd == 1
            give_items(player, RECIPE_GREAT_SWORD_60)
          elsif rnd == 2
            give_items(player, RECIPE_HEAVY_WAR_AXE_60)
          elsif rnd == 3
            give_items(player, RECIPE_SPRITES_STAFF_60)
          elsif rnd == 4
            give_items(player, RECIPE_KESHANBERK_60)
          elsif rnd == 5
            give_items(player, RECIPE_SWORD_OF_VALHALLA_60)
          elsif rnd == 6
            give_items(player, RECIPE_KRIS_60)
          elsif rnd == 7
            give_items(player, RECIPE_HELL_KNIFE_60)
          elsif rnd == 8
            give_items(player, RECIPE_ARTHRO_NAIL_60)
          elsif rnd == 9
            give_items(player, RECIPE_DARK_ELVEN_LONG_BOW_60)
          elsif rnd == 10
            give_items(player, RECIPE_GREAT_AXE_60)
          elsif rnd == 11
            give_items(player, RECIPE_SWORD_OF_DAMASCUS_60)
          elsif rnd == 12
            give_items(player, RECIPE_LANCE_60)
          elsif rnd == 13
            give_items(player, RECIPE_DEADMANS_GLORY_60)
          elsif rnd == 14
            give_items(player, RECIPE_ART_OF_BATTLE_AXE_60)
          elsif rnd == 15
            give_items(player, RECIPE_TAFF_OF_EVIL_SPIRITS_60)
          elsif rnd == 16
            give_items(player, RECIPE_DEMONS_DAGGER_60)
          elsif rnd == 17
            give_items(player, RECIPE_BELLION_CESTUS_60)
          elsif rnd == 18
            give_items(player, RECIPE_BOW_OF_PERIL_60)
          end
        elsif i0 == 5
          give_adena(player, 675000, true)
          rnd = Rnd.rand(18) + 1
          if rnd == 1
            give_items(player, GREAT_SWORD_BLADE)
          elsif rnd == 2
            give_items(player, GREAT_AXE_HEAD)
          elsif rnd == 3
            give_items(player, DARK_ELVEN_LONGBOW_SHAFT)
          elsif rnd == 4
            give_items(player, SWORD_OF_VALHALLA_BLADE)
          elsif rnd == 5
            give_items(player, ARTHRO_NAIL_BLADE)
          elsif rnd == 6
            give_items(player, SPRITES_STAFF_HEAD)
          elsif rnd == 7
            give_items(player, KRIS_EDGE)
          elsif rnd == 8
            give_items(player, KESHANBERK_BLADE)
          elsif rnd == 9
            give_items(player, HEAVY_WAR_AXE_HEAD)
          elsif rnd == 10
            give_items(player, HELL_KNIFE_EDGE)
          elsif rnd == 11
            give_items(player, SWORD_OF_DAMASCUS_BLADE)
          elsif rnd == 12
            give_items(player, LANCE_BLADE)
          elsif rnd == 13
            give_items(player, BELLION_CESTUS_EDGE)
          elsif rnd == 14
            give_items(player, EVIL_SPIRIT_HEAD)
          elsif rnd == 15
            give_items(player, DEADMANS_GLORY_STONE)
          elsif rnd == 16
            give_items(player, ART_OF_BATTLE_AXE_BLADE)
          elsif rnd == 17
            give_items(player, DEMONS_DAGGER_EDGE)
          elsif rnd == 18
            give_items(player, BOW_OF_PERIL_SHAFT)
          end
        elsif i0 == 6
          give_adena(player, 1284000, true)
          give_items(player, SCROLL_ENCHANT_WEAPON_B_GRADE)
          give_items(player, SCROLL_ENCHANT_ARMOR_B_GRADE)
        end
        qs.memo_state = 1
        qs.set_memo_state_ex(1, 0)
        html = event
      end
    when "30846-21a.html"
      if qs.started? && qs.memo_state?(1)
        html = event
      end
    when "30846-22.html"
      if qs.started? && qs.memo_state % 10 == 1
        if get_quest_items_count(player, SPIRIT_BEAD) >= 1
          take_items(player, SPIRIT_BEAD, 1)
          qs.memo_state = 1005
          html = event
        else
          html = "30846-22a.html"
        end
      end
    when "30846-25.html"
      if qs.started? && qs.memo_state?(1005)
        card1pic = qs.get_memo_state_ex(1)
        if card1pic < 0
          card1pic = 0
        end
        card1 = card1pic % 10
        i2 = (card1pic - card1) // 10
        rnd1 = Rnd.rand(2) + 1
        rnd2 = Rnd.rand(5) + 1
        card2pic = (rnd1 * 10) + rnd2
        if rnd1 == i2
          i3 = rnd2 + card1
          if i3 % 5 == 0 && i3 != 10
            qs.memo_state = 1
            qs.set_memo_state_ex(1, 0)
            give_adena(player, 800, true)
            html = get_html(player, "30846-25.html", card1pic, card2pic, -1, card1)
          else
            qs.memo_state = 1006
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-24.html", card1pic, card2pic, -1, -1)
          end
        elsif rnd1 != i2
          if rnd2 == 5 || card1 == 5
            qs.memo_state = 1
            qs.set_memo_state_ex(1, 0)
            give_adena(player, 800, true)
            html = get_html(player, "30846-25.html", card1pic, card2pic, -1, -1)
          else
            qs.memo_state = 1006
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-24.html", card1pic, card2pic, -1, -1)
          end
        end
      end
    when "30846-29.html"
      if qs.started? && qs.memo_state?(1006)
        card1pic = Math.max(qs.get_memo_state_ex(1), 0)
        i1 = card1pic % 10
        i2 = (card1pic - i1) // 10
        rnd1 = Rnd.rand(2) + 1
        rnd2 = Rnd.rand(5) + 1
        card2pic = (rnd1 * 10) + rnd2
        if rnd1 == i2
          i3 = rnd2 + i1
          if i3 % 5 == 0 && i3 != 10
            qs.memo_state = 1
            qs.set_memo_state_ex(1, 0)
            html = get_html(player, "30846-29.html", card1pic, card2pic, 0, -1)
          else
            qs.memo_state = 1005
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-28.html", card1pic, card2pic, 0, -1)
          end
        elsif rnd1 != i2
          if rnd2 == 5 || i1 == 5
            qs.memo_state = 1
            qs.set_memo_state_ex(1, 0)
            html = get_html(player, "30846-29.html", card1pic, card2pic, 0, -1)
          else
            qs.memo_state = 1005
            qs.set_memo_state_ex(1, card2pic)
            html = get_html(player, "30846-28.html", card1pic, card2pic, 0, -1)
          end
        end
      end
    when "30846-30.html"
      if qs.started?
        qs.exit_quest(true)
        html = event
      end
    when "30846-31.html", "30846-32.html"
      if qs.started?
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && qs.memo_state.between?(1, 4)
      players = [killer, killer]
    else
      players = [] of L2PcInstance
    end

    if party = killer.party
      party.members.each do |m|
        m_qs = get_quest_state(m, false)
        if m_qs && m_qs.started? && m_qs.memo_state.between?(1, 4)
          players << m
        end
      end
    end

    unless players.empty?
      winner = players.sample(random: Rnd)
      if Util.in_range?(1500, npc, winner, false)
        rnd = Rnd.rand(1000)

        if npc.id == SPITEFUL_SOUL_LEADER
          if rnd <= SPITEFUL_SOUL_LEADER_CHANCE
            give_items(winner, SPIRIT_BEAD, 2)
          else
            give_items(winner, SPIRIT_BEAD, 1)
          end
        elsif rnd < MONSTERS[npc.id]
          give_items(winner, SPIRIT_BEAD, 1)
          play_sound(winner, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  private def get_html(player, html_name, card1pic, card2pic, win_count, card1)
    html = get_htm(player, html_name).not_nil!
    html = html.sub("<?card1pic?>", card1pic.to_s)
    html = html.sub("<?card2pic?>", card2pic.to_s)
    html = html.sub("<?name?>", player.name)
    if win_count >= 0
      html = html.sub("<?win_count?>", win_count.to_s)
    end
    if card1 >= 0
      html = html.sub("<?card1?>", card1.to_s)
    end

    html
  end
end
