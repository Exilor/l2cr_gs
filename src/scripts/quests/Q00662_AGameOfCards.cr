class Scripts::Q00662_AGameOfCards < Quest
  # NPC
  private KLUMP = 30845
  # Items
  private RED_GEM = 8765
  private ZIGGOS_GEMSTONE = 8868
  # Misc
  private MIN_LEVEL = 61
  private REQUIRED_CHIP_COUNT = 50
  # Monsters
  private MONSTERS = {
    20672 => 357, # Trives
    20673 => 357, # Falibati
    20674 => 583, # Doom Knight
    20677 => 435, # Tulben
    20955 => 358, # Ghostly Warrior
    20958 => 283, # Death Agent
    20959 => 455, # Dark Guard
    20961 => 365, # Bloody Knight
    20962 => 348, # Bloody Priest
    20965 => 457, # Chimera Piece
    20966 => 493, # Changed Creation
    20968 => 418, # Nonexistent Man
    20972 => 350, # Shaman of Ancient Times
    20973 => 453, # Forgotten Ancient People
    21002 => 315, # Doom Scout
    21004 => 320, # Dismal Pole
    21006 => 335, # Doom Servant
    21008 => 462, # Doom Archer
    21010 => 397, # Doom Warrior
    21109 => 507, # Hames Orc Scout
    21112 => 552, # Hames Orc Footman
    21114 => 587, # Cursed Guardian
    21116 => 812, # Hames Orc Overlord
    21278 => 483, # Antelope
    21279 => 483, # Antelope
    21280 => 483, # Antelope
    21286 => 515, # Buffalo
    21287 => 515, # Buffalo
    21288 => 515, # Buffalo
    21508 => 493, # Splinter Stakato
    21510 => 527, # Splinter Stakato Soldier
    21513 => 562, # Needle Stakato
    21515 => 598, # Needle Stakato Soldier
    21520 => 458, # Eye of Splendor
    21526 => 552, # Wisdom of Splendor
    21530 => 488, # Victory of Splendor
    21535 => 573, # Signet of Splendor
    18001 => 232  # Blood Queen
  }

  def initialize
    super(662, self.class.simple_name, "A Game of Cards")

    add_start_npc(KLUMP)
    add_talk_id(KLUMP)
    add_kill_id(MONSTERS.keys)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = nil
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30845-03.htm"
      if pc.level >= MIN_LEVEL
        if st.created?
          st.start_quest
        end
        html = event
      end
    when "30845-06.html", "30845-08.html", "30845-09.html", "30845-09a.html",
         "30845-09b.html", "30845-10.html"
      html = event
    when "30845-07.html"
      st.exit_quest(true, true)
      html = event
    when "return"
      if st.get_quest_items_count(RED_GEM) < REQUIRED_CHIP_COUNT
        html = "30845-04.html"
      else
        html = "30845-05.html"
      end
    when "30845-11.html"
      if st.get_quest_items_count(RED_GEM) >= REQUIRED_CHIP_COUNT
        i1 = 0
        i2 = 0
        i3 = 0
        i4 = 0
        i5 = 0

        while i1 == i2 || i1 == i3 || i1 == i4 || i1 == i5 || i2 == i3 || i2 == i4 || i2 == i5 || i3 == i4 || i3 == i5 || i4 == i5
          i1 = Rnd.rand(70) + 1
          i2 = Rnd.rand(70) + 1
          i3 = Rnd.rand(70) + 1
          i4 = Rnd.rand(70) + 1
          i5 = Rnd.rand(70) + 1
        end

        if i1 >= 57
          i1 = i1 - 56
        elsif i1 >= 43
          i1 = i1 - 42
        elsif i1 >= 29
          i1 = i1 - 28
        elsif i1 >= 15
          i1 = i1 - 14
        end

        if i2 >= 57
          i2 = i2 - 56
        elsif i2 >= 43
          i2 = i2 - 42
        elsif i2 >= 29
          i2 = i2 - 28
        elsif i2 >= 15
          i2 = i2 - 14
        end

        if i3 >= 57
          i3 = i3 - 56
        elsif i3 >= 43
          i3 = i3 - 42
        elsif i3 >= 29
          i3 = i3 - 28
        elsif i3 >= 15
          i3 = i3 - 14
        end

        if i4 >= 57
          i4 = i4 - 56
        elsif i4 >= 43
          i4 = i4 - 42
        elsif i4 >= 29
          i4 = i4 - 28
        elsif i4 >= 15
          i4 = i4 - 14
        end

        if i5 >= 57
          i5 = i5 - 56
        elsif i5 >= 43
          i5 = i5 - 42
        elsif i5 >= 29
          i5 = i5 - 28
        elsif i5 >= 15
          i5 = i5 - 14
        end

        st.set("v1", (i4 * 1000000) + (i3 * 10000) + (i2 * 100) + i1)
        st.set("ExMemoState", i5)
        st.take_items(RED_GEM, REQUIRED_CHIP_COUNT)
        html = event
      end
    when "turncard1", "turncard2", "turncard3", "turncard4", "turncard5"
      cond = st.get_int("v1")
      i1 = st.get_int("ExMemoState")
      i5 = i1 % 100
      i9 = i1 // 100
      i1 = cond % 100
      i2 = (cond % 10000) // 100
      i3 = (cond % 1000000) // 10000
      i4 = (cond % 100000000) // 1000000
      case event
      when "turncard1"
        if i9 % 2 < 1
          i9 = i9 + 1
        end
        if i9 % 32 < 31
          st.set("ExMemoState", (i9 * 100) + i5)
        end
      when "turncard2"
        if i9 % 4 < 2
          i9 = i9 + 2
        end
        if i9 % 32 < 31
          st.set("ExMemoState", (i9 * 100) + i5)
        end
      when "turncard3"
        if i9 % 8 < 4
          i9 = i9 + 4
        end
        if i9 % 32 < 31
          st.set("ExMemoState", (i9 * 100) + i5)
        end
      when "turncard4"
        if i9 % 16 < 8
          i9 = i9 + 8
        end
        if i9 % 32 < 31
          st.set("ExMemoState", (i9 * 100) + i5)
        end
      when "turncard5"
        if i9 % 32 < 16
          i9 = i9 + 16
        end
        if i9 % 32 < 31
          st.set("ExMemoState", (i9 * 100) + i5)
        end
      else
        # [automatically added else]
      end


      if i9 % 32 < 31
        html = get_htm(pc, "30845-12.html")
      elsif i9 % 32 == 31
        i6 = 0
        i8 = 0
        if {i1, i2, i3, i4, i5}.all? &.between?(1, 14)
          if i1 == i2
            i6 = i6 + 10
            i8 = i8 + 8
          end
          if i1 == i3
            i6 = i6 + 10
            i8 = i8 + 4
          end
          if i1 == i4
            i6 = i6 + 10
            i8 = i8 + 2
          end
          if i1 == i5
            i6 = i6 + 10
            i8 = i8 + 1
          end
          if i6 % 100 < 10
            if i8 % 16 < 8
              if i8 % 8 < 4
                if i2 == i3
                  i6 = i6 + 10
                  i8 = i8 + 4
                end
              end
              if i8 % 4 < 2
                if i2 == i4
                  i6 = i6 + 10
                  i8 = i8 + 2
                end
              end
              if i8 % 2 < 1
                if i2 == i5
                  i6 = i6 + 10
                  i8 = i8 + 1
                end
              end
            end
          elsif i6 % 10 == 0
            if i8 % 16 < 8
              if i8 % 8 < 4
                if i2 == i3
                  i6 = i6 + 1
                  i8 = i8 + 4
                end
              end
              if i8 % 4 < 2
                if i2 == i4
                  i6 = i6 + 1
                  i8 = i8 + 2
                end
              end
              if i8 % 2 < 1
                if i2 == i5
                  i6 = i6 + 1
                  i8 = i8 + 1
                end
              end
            end
          end
          if i6 % 100 < 10
            if i8 % 8 < 4
              if i8 % 4 < 2
                if i3 == i4
                  i6 = i6 + 10
                  i8 = i8 + 2
                end
              end
              if i8 % 2 < 1
                if i3 == i5
                  i6 = i6 + 10
                  i8 = i8 + 1
                end
              end
            end
          elsif i6 % 10 == 0
            if i8 % 8 < 4
              if i8 % 4 < 2
                if i3 == i4
                  i6 = i6 + 1
                  i8 = i8 + 2
                end
              end
              if i8 % 2 < 1
                if i3 == i5
                  i6 = i6 + 1
                  i8 = i8 + 1
                end
              end
            end
          end
          if i6 % 100 < 10
            if i8 % 4 < 2
              if i8 % 2 < 1
                if i4 == i5
                  i6 = i6 + 10
                  i8 = i8 + 1
                end
              end
            end
          elsif i6 % 10 == 0
            if i8 % 4 < 2
              if i8 % 2 < 1
                if i4 == i5
                  i6 = i6 + 1
                  i8 = i8 + 1
                end
              end
            end
          end
        end

        if i6 == 40
          reward_items(pc, ZIGGOS_GEMSTONE, 43)
          reward_items(pc, 959, 3)
          reward_items(pc, 729, 1)
          st.set("ExMemoState", 0)
          st.set("v1", 0)
          html = get_htm(pc, "30845-13.html")
        elsif i6 == 30
          reward_items(pc, 959, 2)
          reward_items(pc, 951, 2)
          st.set("ExMemoState", 0)
          st.set("v1", 0)
          html = get_htm(pc, "30845-14.html")
        elsif i6 == 21 || i6 == 12
          reward_items(pc, 729, 1)
          reward_items(pc, 947, 2)
          reward_items(pc, 955, 1)
          st.set("ExMemoState", 0)
          st.set("v1", 0)
          html = get_htm(pc, "30845-15.html")
        elsif i6 == 20
          reward_items(pc, 951, 2)
          st.set("ExMemoState", 0)
          st.set("v1", 0)
          html = get_htm(pc, "30845-16.html")
        elsif i6 == 11
          reward_items(pc, 951, 1)
          st.set("ExMemoState", 0)
          st.set("v1", 0)
          html = get_htm(pc, "30845-17.html")
        elsif i6 == 10
          reward_items(pc, 956, 2)
          st.set("ExMemoState", 0)
          st.set("v1", 0)
          html = get_htm(pc, "30845-18.html")
        elsif i6 == 0
          st.set("ExMemoState", 0)
          st.set("v1", 0)
          html = get_htm(pc, "30845-19.html")
        end
      end

      if html
        if i9 % 2 < 1
          html = html.gsub("FontColor1", "FFFF00")
          html = html.gsub("Cell1", "?")
        else
          html = html.gsub("FontColor1", "FF6F6F")
          html = set_html(html, i1, "Cell1")
        end
        if i9 % 4 < 2
          html = html.gsub("FontColor2", "FFFF00")
          html = html.gsub("Cell2", "?")
        else
          html = html.gsub("FontColor2", "FF6F6F")
          html = set_html(html, i2, "Cell2")
        end
        if i9 % 8 < 4
          html = html.gsub("FontColor3", "FFFF00")
          html = html.gsub("Cell3", "?")
        else
          html = html.gsub("FontColor3", "FF6F6F")
          html = set_html(html, i3, "Cell3")
        end
        if i9 % 16 < 8
          html = html.gsub("FontColor4", "FFFF00")
          html = html.gsub("Cell4", "?")
        else
          html = html.gsub("FontColor4", "FF6F6F")
          html = set_html(html, i4, "Cell4")
        end
        if i9 % 32 < 16
          html = html.gsub("FontColor5", "FFFF00")
          html = html.gsub("Cell5", "?")
        else
          html = html.gsub("FontColor5", "FF6F6F")
          html = set_html(html, i5, "Cell5")
        end
      end
    when "playagain"
      if st.get_quest_items_count(RED_GEM) < REQUIRED_CHIP_COUNT
        html = "30845-21.html"
      else
        html = "30845-20.html"
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level < MIN_LEVEL ? "30845-02.html" : "30845-01.htm"
    when State::STARTED
      if st.cond?(1)
        if st.get_quest_items_count(RED_GEM) < REQUIRED_CHIP_COUNT
          html = "30845-04.html"
        else
          html = "30845-05.html"
        end
      elsif st.get_int("ExMemoState") != 0
        i0 = st.get_int("v1")
        i1 = st.get_int("ExMemoState")
        i5 = i1 % 100
        i9 = i1 // 100
        i1 = i0 % 100
        i2 = (i0 % 10000) // 100
        i3 = (i0 % 1000000) // 10000
        i4 = (i0 % 100000000) // 1000000
        html = get_htm(pc, "30845-11a.html")

        if i9 % 2 < 1
          html = html.gsub("FontColor1", "FFFF00")
          html = html.gsub("Cell1", "?")
        else
          html = html.gsub("FontColor1", "FF6F6F")
          html = set_html(html, i1, "Cell1")
        end

        if i9 % 4 < 2
          html = html.gsub("FontColor2", "FFFF00")
          html = html.gsub("Cell2", "?")
        else
          html = html.gsub("FontColor2", "FF6F6F")
          html = set_html(html, i2, "Cell2")
        end

        if i9 % 8 < 4
          html = html.gsub("FontColor3", "FFFF00")
          html = html.gsub("Cell3", "?")
        else
          html = html.gsub("FontColor3", "FF6F6F")
          html = set_html(html, i3, "Cell3")
        end
        if i9 % 16 < 8
          html = html.gsub("FontColor4", "FFFF00")
          html = html.gsub("Cell4", "?")
        else
          html = html.gsub("FontColor4", "FF6F6F")
          html = set_html(html, i4, "Cell4")
        end
        if i9 % 32 < 16
          html = html.gsub("FontColor5", "FFFF00")
          html = html.gsub("Cell5", "?")
        else
          html = html.gsub("FontColor5", "FF6F6F")
          html = set_html(html, i5, "Cell5")
        end
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    pcs = [killer, killer]

    if party = killer.party
      party.members.each do |m|
        if get_quest_state(m, false)
          pcs << m
        end
      end
    end

    pc = pcs.sample(random: Rnd)
    if Util.in_range?(1500, npc, pc, false) && MONSTERS[npc.id] < Rnd.rand(1000)
      if st = get_quest_state(pc, false)
        give_item_randomly(st.player, npc, RED_GEM, 1, 0, MONSTERS[npc.id].to_f, true)
      end
    end

    super
  end

  private def set_html(html, var, regex)
    replacement =
    case var
    when 1 then "!"
    when 2 then "="
    when 3 then "T"
    when 4 then "V"
    when 5 then "O"
    when 6 then "P"
    when 7 then "S"
    when 8 then "E"
    when 9 then "H"
    when 10 then "A"
    when 11 then "R"
    when 12 then "D"
    when 13 then "I"
    when 14 then "N"
    else "ERROR"
    end

    html.gsub(regex, replacement)
  end
end
