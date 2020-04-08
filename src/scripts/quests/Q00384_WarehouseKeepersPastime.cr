class Scripts::Q00384_WarehouseKeepersPastime < Quest
  # NPCs
  private CLIFF = 30182
  private WAREHOUSE_CHIEF_BAXT = 30685

  # Monsters
  private DUST_WIND = 20242
  private INNERSEN = 20950
  private CONGERER = 20774
  private CARINKAIN = 20635
  private CONNABI = 20947
  private HUNTER_GARGOYLE = 20241
  private NIGHTMARE_GUIDE = 20942
  private DRAGON_BEARER_WARRIOR = 20759
  private DRAGON_BEARER_CHIEF = 20758
  private DUST_WIND_HOLD = 20281
  private WEIRD_DRAKE = 20605
  private THUNDER_WYRM_HOLD = 20282
  private CADEINE = 20945
  private CONGERER_LORD = 20773
  private DRAGON_BEARER_ARCHER = 20760
  private NIGHTMARE_LORD = 20944
  private SANHIDRO = 20946
  private GIANT_MONSTEREYE = 20556
  private BARTAL = 20948
  private HUNTER_GARGOYLE_HOLD = 20286
  private ROT_GOLEM = 20559
  private GRAVE_GUARD = 20668
  private TULBEN = 20677
  private NIGHTMARE_KEEPER = 20943
  private LUMINUN = 20949
  private THUNDER_WYRM = 20243
  # Items
  private Q_IRONGATE_MEDAL = 5964
  # Reward
  private MOONSTONE_EARING = 852
  private DRAKE_LEATHER_BOOTS = 2437
  private DRAKE_LEATHER_MAIL = 401
  private MOLD_HARDENER = 4041
  private NECKLACE_OF_MERMAID = 917
  private SCRL_OF_ENCH_AM_C = 952
  private BLACKSMITH_S_FRAME = 1892
  private SCRL_OF_ENCH_WP_C = 951
  private ORIHARUKON = 1893
  private SAMURAI_LONGSWORD = 135
  private AQUASTONE_RING = 883
  private SYNTHESIS_COKES = 1888
  private MITHIRL_ALLOY = 1890
  private GREAT_HELMET = 500
  private VARNISH_OF_PURITY = 1887
  private BLESSED_GLOVES = 2463
  private CRAFTED_LEATHER = 1894

  def initialize
    super(384, self.class.simple_name, "Warehouse Keeper's Pastime")

    add_start_npc(CLIFF)
    add_talk_id(CLIFF, WAREHOUSE_CHIEF_BAXT)
    add_kill_id(
      WAREHOUSE_CHIEF_BAXT, DUST_WIND, INNERSEN, CLIFF, CONGERER, CARINKAIN,
      CONNABI, HUNTER_GARGOYLE, NIGHTMARE_GUIDE, DRAGON_BEARER_WARRIOR, BARTAL,
      DRAGON_BEARER_CHIEF, DUST_WIND_HOLD, WEIRD_DRAKE, THUNDER_WYRM_HOLD,
      CADEINE, CONGERER_LORD, DRAGON_BEARER_ARCHER, NIGHTMARE_LORD, SANHIDRO,
      GIANT_MONSTEREYE, HUNTER_GARGOYLE_HOLD, ROT_GOLEM, GRAVE_GUARD, TULBEN,
      NIGHTMARE_KEEPER, LUMINUN, THUNDER_WYRM
    )
    register_quest_items(Q_IRONGATE_MEDAL)
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when CLIFF
      if qs.created?
        if pc.level >= 40
          return "30182-01.htm"
        end
        return "30182-04.html"
      end
      if qs.get_quest_items_count(Q_IRONGATE_MEDAL) < 10
        return "30182-06.html"
      end
      return "30182-07.html"
    when WAREHOUSE_CHIEF_BAXT
      if qs.has_memo_state?
        if qs.get_quest_items_count(Q_IRONGATE_MEDAL) < 10
          return "30685-06.html"
        end
        return "30685-07.html"
      end
    else
      # automatically added
    end


    get_no_quest_msg(pc)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    npc = npc.not_nil!

    if qs = get_quest_state(pc, false)
      if event.includes?(".htm")
        return event
      end

      case npc.id
      when CLIFF
        if event == "QUEST_ACCEPTED"
          qs.play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
          qs.memo_state = 384
          qs.start_quest
          qs.show_question_mark(384)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30182-05.htm"
        end

        case ask = event.to_i
        when 3
          return "30182-09a.htm"
        when 4
          return "30182-02.htm"
        when 5
          if npc.id != CLIFF
            return get_no_quest_msg(pc)
          end

          return "30182-03.htm"
        when 6
          qs.exit_quest(true)
          return "30182-08.html"
        when 9
          return "30182-09.html"
        when 7
          if qs.get_quest_items_count(Q_IRONGATE_MEDAL) >= 10
            qs.take_items(Q_IRONGATE_MEDAL, 10)
            qs.memo_state = 10
            create_bingo_board(qs)
            return "30182-10.html"
          end
          return "30182-11.html"
        when 8
          if qs.get_quest_items_count(Q_IRONGATE_MEDAL) >= 100
            qs.take_items(Q_IRONGATE_MEDAL, 100)
            qs.memo_state = 20
            create_bingo_board(qs)
            return "30182-12.html"
          end
          return "30182-11.html"
        when 10..18
          select_bingo_number(qs, ask - 10 + 1)
          return fill_board(pc, qs, get_htm(pc, "30182-13.html"))
        when 19..27
          return take_html(pc, qs, ask - 18, CLIFF)
        when 55..63
          return before_reward(pc, qs, ask - 54, CLIFF)
        else
          # automatically added
        end

      when WAREHOUSE_CHIEF_BAXT
        ask = event.to_i
        case ask
        when 3
          return "30685-09a.html"
        when 6
          qs.exit_quest(true)
          return "30685-08.html"
        when 9
          return "30685-09.html"
        when 7
          if qs.get_quest_items_count(Q_IRONGATE_MEDAL) >= 10
            qs.take_items(Q_IRONGATE_MEDAL, 10)
            qs.memo_state = 10
            create_bingo_board(qs)
            return "30685-10.html"
          end
          return "30685-11.html"
        when 8
          if qs.get_quest_items_count(Q_IRONGATE_MEDAL) >= 100
            qs.take_items(Q_IRONGATE_MEDAL, 100)
            qs.memo_state = 20
            create_bingo_board(qs)
            return "30685-12.html"
          end
          return "30685-11.html"
        when 10..18
          select_bingo_number(qs, ask - 9)
          return fill_board(pc, qs, get_htm(pc, "30685-13.html"))
        when 19..27
          return take_html(pc, qs, ask - 18, WAREHOUSE_CHIEF_BAXT)
        when 55..63
          return before_reward(pc, qs, ask - 54, WAREHOUSE_CHIEF_BAXT)
        else
          # automatically added
        end

      else
        # automatically added
      end

    end

    super
  end

  private def take_html(pc, qs, num, npc_id)
    html = nil

    unless selected_bingo_number?(qs, num)
      select_bingo_number(qs, num)
      i3 = get_bingo_select_count(qs)

      if i3 == 2
        html = get_htm(pc, "#{npc_id}-14.html")
      elsif i3 == 3
        html = get_htm(pc, "#{npc_id}-16.html")
      elsif i3 == 4
        html = get_htm(pc, "#{npc_id}-18.html")
      elsif i3 == 5
        html = get_htm(pc, "#{npc_id}-20.html")
      end

      return fill_board(pc, qs, html.not_nil!)
    end

    i3 = get_bingo_select_count(qs)
    if i3 == 1
      html = get_htm(pc, "#{npc_id}-15.html")
    elsif i3 == 2
      html = get_htm(pc, "#{npc_id}-17.html")
    elsif i3 == 3
      html = get_htm(pc, "#{npc_id}-19.html")
    elsif i3 == 4
      html = get_htm(pc, "#{npc_id}-21.html")
    end

    fill_board(pc, qs, html.not_nil!)
  end

  private def fill_board(pc, qs, html : String)
    9.times do |i0|
      i1 = get_number_from_bingo_board(qs, i0)
      if selected_bingo_number?(qs, i1)
        html = html.sub("<?Cell#{i0 + 1}?>", i1.to_s)
      else
        html = html.sub("<?Cell#{i0 + 1}?>", "?")
      end
    end

    html
  end

  private def color_board(pc, qs, html : String)
    9.times do |i0|
      i1 = get_number_from_bingo_board(qs, i0)
      html = html.sub("<?FontColor#{i0 + 1}?>", selected_bingo_number?(qs, i1) ? "ff0000" : "ffffff")
      html = html.sub("<?Cell#{i0 + 1}?>", i1.to_s)
    end

    html
  end

  private def before_reward(pc, qs, num, npc_id)
    unless selected_bingo_number?(qs, num)
      select_bingo_number(qs, num)
      i3 = get_matched_bingo_line_count(qs)
      if i3 == 3 && get_bingo_select_count(qs) == 6
        reward(pc, qs, i3)
        html = get_htm(pc, "#{npc_id}-22.html")
      elsif i3 == 0 && get_bingo_select_count(qs) == 6
        reward(pc, qs, i3)
        html = get_htm(pc, "#{npc_id}-24.html")
      else
        html = get_htm(pc, "#{npc_id}-23.html")
      end

      return color_board(pc, qs, html)
    end

    fill_board(pc, qs, get_htm(pc, "#{npc_id}-25.html"))
  end

  private def reward(pc, qs, i3)
    if i3 == 3
      if qs.memo_state == 10
        random = Rnd.rand(100)
        if random < 16
          qs.give_items(SYNTHESIS_COKES, 1)
        elsif random < 32
          qs.give_items(VARNISH_OF_PURITY, 1)
        elsif random < 50
          qs.give_items(CRAFTED_LEATHER, 1)
        elsif random < 80
          qs.give_items(SCRL_OF_ENCH_AM_C, 1)
        elsif random < 89
          qs.give_items(MITHIRL_ALLOY, 1)
        elsif random < 98
          qs.give_items(ORIHARUKON, 1)
        else
          qs.give_items(SCRL_OF_ENCH_WP_C, 1)
        end

      elsif qs.memo_state == 20
        random = Rnd.rand(100)

        if random < 50
          qs.give_items(AQUASTONE_RING, 1)
        elsif random < 80
          qs.give_items(SCRL_OF_ENCH_WP_C, 1)
        elsif random < 98
          qs.give_items(MOONSTONE_EARING, 1)
        else
          qs.give_items(DRAKE_LEATHER_MAIL, 1)
        end
      end
    elsif i3 == 0
      if qs.memo_state == 10
        random = Rnd.rand(100)

        if random < 50
          qs.give_items(MOLD_HARDENER, 1)
        elsif random < 80
          qs.give_items(SCRL_OF_ENCH_AM_C, 1)
        elsif random < 98
          qs.give_items(BLACKSMITH_S_FRAME, 1)
        else
          qs.give_items(NECKLACE_OF_MERMAID, 1)
        end
      elsif qs.memo_state == 20
        random = Rnd.rand(100)

        if random < 50
          qs.give_items(SCRL_OF_ENCH_WP_C, 1)
        elsif random < 80
          qs.give_items(GREAT_HELMET, 1)
        elsif random < 98
          qs.give_items(DRAKE_LEATHER_BOOTS, 1)
          qs.give_items(BLESSED_GLOVES, 1)
        else
          qs.give_items(SAMURAI_LONGSWORD, 1)
        end
      end
    end
  end

  private def create_bingo_board(qs)
    ary = 1.upto(9).to_a.shuffle!(random: Rnd)
    qs.set("numbers", ary.to_s.gsub(/[^\\d ]/, ""))
    qs.set("selected", "? ? ? ? ? ? ? ? ?")
  end

  private def get_matched_bingo_line_count(qs)
    q = qs.get("selected").not_nil!.split
    found = 0
    # Horizontal
    if (q[0] + q[1] + q[2]).match?(/\\d+/)
      found += 1
    end
    if (q[3] + q[4] + q[5]).match?(/\\d+/)
      found += 1
    end
    if (q[6] + q[7] + q[8]).match?(/\\d+/)
      found += 1
    end
    # Vertical
    if (q[0] + q[3] + q[6]).match?(/\\d+/)
      found += 1
    end
    if (q[1] + q[4] + q[7]).match?(/\\d+/)
      found += 1
    end
    if (q[2] + q[5] + q[8]).match?(/\\d+/)
      found += 1
    end
    # Diagonal
    if (q[0] + q[4] + q[8]).match?(/\\d+/)
      found += 1
    end
    if (q[2] + q[4] + q[6]).match?(/\\d+/)
      found += 1
    end

    found
  end

  private def select_bingo_number(qs, num)
    numbers = qs.get("numbers").not_nil!.split
    pos = 0
    numbers.size.times do |i|
      if numbers[i].to_i == num
        pos = i
      end
    end
    selected = qs.get("selected").not_nil!.split
    selected.size.times do |i|
      if i == pos
        selected[i] = num.to_s
        next
      end
    end
    result = selected[0]
    selected.size.times do |i|
      result += selected[i].to_s
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
    current.gsub(/\\D/, "").size
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_player_from_party(killer, npc)
      case npc.id
      when HUNTER_GARGOYLE
        if Rnd.rand(1000) < 328
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when DUST_WIND
        if Rnd.rand(100) < 35
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when THUNDER_WYRM
        if Rnd.rand(1000) < 312
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when DUST_WIND_HOLD
        if Rnd.rand(100) < 35
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when THUNDER_WYRM_HOLD
        if Rnd.rand(1000) < 312
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when HUNTER_GARGOYLE_HOLD
        if Rnd.rand(1000) < 328
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when GIANT_MONSTEREYE
        if Rnd.rand(1000) < 176
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when ROT_GOLEM
        if Rnd.rand(1000) < 226
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when WEIRD_DRAKE
        if Rnd.rand(1000) < 218
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when CARINKAIN
        if Rnd.rand(1000) < 216
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when GRAVE_GUARD
        if Rnd.rand(1000) < 312
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when TULBEN
        if Rnd.rand(1000) < 522
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when DRAGON_BEARER_CHIEF
        if Rnd.rand(100) < 38
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when DRAGON_BEARER_WARRIOR
        if Rnd.rand(100) < 39
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when DRAGON_BEARER_ARCHER
        if Rnd.rand(1000) < 372
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when CONGERER_LORD
        if Rnd.rand(1000) < 802
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when CONGERER
        if Rnd.rand(1000) < 844
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when NIGHTMARE_GUIDE
        if Rnd.rand(1000) < 118
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when NIGHTMARE_KEEPER
        if Rnd.rand(100) < 17
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when NIGHTMARE_LORD
        if Rnd.rand(1000) < 144
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when CADEINE
        if Rnd.rand(1000) < 162
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when SANHIDRO
        if Rnd.rand(100) < 25
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when CONNABI
        if Rnd.rand(1000) < 272
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when BARTAL
        if Rnd.rand(100) < 27
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when LUMINUN
        if Rnd.rand(100) < 32
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      when INNERSEN
        if Rnd.rand(1000) < 346
          give_item_randomly(qs.player, npc, Q_IRONGATE_MEDAL, 1, 0, 1, true)
        end
      else
        # automatically added
      end

    end

    super
  end

  private def get_random_player_from_party(pc, npc)
    qs = get_quest_state(pc, false)

    if qs && qs.started?
      candidates = [qs, qs]
    else
      candidates = [] of QuestState
    end

    if party = pc.party
      party.members.each do |pm|

        qss = get_quest_state(pm, false)
        if qss && qss.started? && Util.in_range?(1500, npc, pm, true)
          candidates << qss
        end
      end
    end

    candidates.sample?(random: Rnd)
  end
end