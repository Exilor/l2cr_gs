class Scripts::Q00620_FourGoblets < Quest
  # NPCs
  private GHOST_OF_WIGOTH_1 = 31452
  private NAMELESS_SPIRIT = 31453
  private GHOST_OF_WIGOTH_2 = 31454
  private GHOST_CHAMBERLAIN_OF_ELMOREDEN_1 = 31919
  private CONQUERORS_SEPULCHER_MANAGER = 31921
  private EMPERORS_SEPULCHER_MANAGER = 31922
  private GREAT_SAGES_SEPULCHER_MANAGER = 31923
  private JUDGES_SEPULCHER_MANAGER = 31924
  # Items
  private BROKEN_RELIC_PART = 7254
  private SEALED_BOX = 7255
  private GOBLET_OF_ALECTIA = 7256
  private GOBLET_OF_TISHAS = 7257
  private GOBLET_OF_MEKARA = 7258
  private GOBLET_OF_MORIGUL = 7259
  private CHAPEL_KEY = 7260
  private USED_GRAVE_PASS = 7261
  private ANTIQUE_BROOCH = 7262
  # Misc
  private MIN_LEVEL = 74
  # Locations
  private ENTER_LOC = Location.new(170000, -88250, -2912, 0)
  private EXIT_LOC = Location.new(169584, -91008, -2912, 0)
  # Rewards
  private CORD = ItemHolder.new(1884, 42)
  private METALLIC_FIBER = ItemHolder.new(1895, 36)
  private MITHRIL_ORE = ItemHolder.new(1876, 4)
  private COARSE_BONE_POWDER = ItemHolder.new(1881, 6)
  private METALLIC_THREAD = ItemHolder.new(5549, 8)
  private ORIHARUKON_ORE = ItemHolder.new(1874, 1)
  private COMPOUND_BRAID = ItemHolder.new(1889, 1)
  private ADAMANTITE_NUGGET = ItemHolder.new(1877, 1)
  private CRAFTED_LEATHER = ItemHolder.new(1894, 1)
  private ASOFE = ItemHolder.new(4043, 1)
  private SYNTETHIC_COKES = ItemHolder.new(1888, 1)
  private MOLD_LUBRICANT = ItemHolder.new(4040, 1)
  private MITHRIL_ALLOY = ItemHolder.new(1890, 1)
  private DURABLE_METAL_PLATE = ItemHolder.new(5550, 1)
  private ORIHARUKON = ItemHolder.new(1893, 1)
  private MAESTRO_ANVIL_LOCK = ItemHolder.new(4046, 1)
  private MAESTRO_MOLD = ItemHolder.new(4048, 1)
  private BRAIDED_HEMP = ItemHolder.new(1878, 8)
  private LEATHER = ItemHolder.new(1882, 24)
  private COKES = ItemHolder.new(1879, 4)
  private STEEL = ItemHolder.new(1880, 6)
  private HIGH_GRADE_SUEDE = ItemHolder.new(1885, 6)
  private STONE_OF_PURITY = ItemHolder.new(1875, 1)
  private STEEL_MOLD = ItemHolder.new(1883, 1)
  private METAL_HARDENER = ItemHolder.new(5220, 1)
  private MOLD_GLUE = ItemHolder.new(4039, 1)
  private THONS = ItemHolder.new(4044, 1)
  private VARNISH_OF_PURITY = ItemHolder.new(1887, 1)
  private ENRIA = ItemHolder.new(4042, 1)
  private SILVER_MOLD = ItemHolder.new(1886, 1)
  private MOLD_HARDENER = ItemHolder.new(4041, 1)
  private BLACKSMITHS_FRAMES = ItemHolder.new(1892, 1)
  private ARTISANS_FRAMES = ItemHolder.new(1891, 1)
  private CRAFTSMAN_MOLD = ItemHolder.new(4047, 1)
  private ENCHANT_ARMOR_A_GRADE = ItemHolder.new(730, 1)
  private ENCHANT_ARMOR_B_GRADE = ItemHolder.new(948, 1)
  private ENCHANT_ARMOR_S_GRADE = ItemHolder.new(960, 1)
  private ENCHANT_WEAPON_A_GRADE = ItemHolder.new(729, 1)
  private ENCHANT_WEAPON_B_GRADE = ItemHolder.new(947, 1)
  private ENCHANT_WEAPON_S_GRADE = ItemHolder.new(959, 1)
  private SEALED_TATEOSSIAN_EARRING_PART = ItemHolder.new(6698, 1)
  private SEALED_TATEOSSIAN_RING_GEM = ItemHolder.new(6699, 1)
  private SEALED_TATEOSSIAN_NECKLACE_CHAIN = ItemHolder.new(6700, 1)
  private SEALED_IMPERIAL_CRUSADER_BREASTPLATE_PART = ItemHolder.new(6701, 1)
  private SEALED_IMPERIAL_CRUSADER_GAITERS_PATTERN = ItemHolder.new(6702, 1)
  private SEALED_IMPERIAL_CRUSADER_GAUNTLETS_DESIGN = ItemHolder.new(6703, 1)
  private SEALED_IMPERIAL_CRUSADER_BOOTS_DESIGN = ItemHolder.new(6704, 1)
  private SEALED_IMPERIAL_CRUSADER_SHIELD_PART = ItemHolder.new(6705, 1)
  private SEALED_IMPERIAL_CRUSADER_HELMET_PATTERN = ItemHolder.new(6706, 1)
  private SEALED_DRACONIC_LEATHER_ARMOR_PART = ItemHolder.new(6707, 1)
  private SEALED_DRACONIC_LEATHER_GLOVES_FABRIC = ItemHolder.new(6708, 1)
  private SEALED_DRACONIC_LEATHER_BOOTS_DESIGN = ItemHolder.new(6709, 1)
  private SEALED_DRACONIC_LEATHER_HELMET_PATTERN = ItemHolder.new(6710, 1)
  private SEALED_MAJOR_ARCANA_ROBE_PART = ItemHolder.new(6711, 1)
  private SEALED_MAJOR_ARCANA_GLOVES_FABRIC = ItemHolder.new(6712, 1)
  private SEALED_MAJOR_ARCANA_BOOTS_DESIGN = ItemHolder.new(6713, 1)
  private SEALED_MAJOR_ARCANA_CIRCLET_PATTERN = ItemHolder.new(6714, 1)
  private FORGOTTEN_BLADE_EDGE = ItemHolder.new(6688, 1)
  private BASALT_BATTLEHAMMER_HEAD = ItemHolder.new(6689, 1)
  private IMPERIAL_STAFF_HEAD = ItemHolder.new(6690, 1)
  private ANGEL_SLAYER_BLADE = ItemHolder.new(6691, 1)
  private DRACONIC_BOW_SHAFT = ItemHolder.new(7579, 1)
  private DRAGON_HUNTER_AXE_BLADE = ItemHolder.new(6693, 1)
  private SAINT_SPEAR_BLADE = ItemHolder.new(6694, 1)
  private DEMON_SPLINTER_BLADE = ItemHolder.new(6695, 1)
  private HEAVENS_DIVIDER_EDGE = ItemHolder.new(6696, 1)
  private ARCANA_MACE_HEAD = ItemHolder.new(6697, 1)
  # Mobs
  private HALISHA_ALECTIA = 25339
  private HALISHA_TISHAS = 25342
  private HALISHA_MEKARA = 25346
  private HALISHA_MORIGUL = 25349

  private MOB1 = {
    18141 => 0.9,
    18142 => 0.9,
    18143 => 0.9,
    18144 => 0.9,
    18145 => 0.76,
    18146 => 0.78,
    18147 => 0.73,
    18148 => 0.85,
    18149 => 0.75,
    18230 => 0.58
  }
  private MOB2 = {
    18120 => 51,
    18121 => 44,
    18122 => 10,
    18123 => 51,
    18124 => 44,
    18125 => 10,
    18126 => 51,
    18127 => 44,
    18128 => 10,
    18129 => 51,
    18130 => 44,
    18131 => 10,
    18132 => 54,
    18133 => 42,
    18134 => 7,
    18135 => 42,
    18136 => 42,
    18137 => 6,
    18138 => 41,
    18139 => 39,
    18140 => 41,
    18166 => 8,
    18167 => 7,
    18168 => 10,
    18169 => 6,
    18170 => 7,
    18171 => 11,
    18172 => 6,
    18173 => 17,
    18174 => 45,
    18175 => 10,
    18176 => 17,
    18177 => 45,
    18178 => 10,
    18179 => 17,
    18180 => 45,
    18181 => 10,
    18182 => 17,
    18183 => 45,
    18184 => 10,
    18185 => 46,
    18186 => 47,
    18187 => 42,
    18188 => 7,
    18189 => 42,
    18190 => 42,
    18191 => 6,
    18192 => 41,
    18193 => 39,
    18194 => 41,
    18195 => 8,
    18220 => 47,
    18221 => 51,
    18222 => 43,
    18223 => 7,
    18224 => 44,
    18225 => 43,
    18226 => 6,
    18227 => 82,
    18229 => 41
  }
  private MOB3 = {
    18212 => 50,
    18213 => 50,
    18214 => 50,
    18215 => 50,
    18216 => 50,
    18217 => 50,
    18218 => 50,
    18219 => 50
  }

  def initialize
    super(620, self.class.simple_name, "Four Goblets")

    add_start_npc(NAMELESS_SPIRIT)
    add_talk_id(
      NAMELESS_SPIRIT, GHOST_OF_WIGOTH_1, GHOST_OF_WIGOTH_2,
      GHOST_CHAMBERLAIN_OF_ELMOREDEN_1, CONQUERORS_SEPULCHER_MANAGER,
      EMPERORS_SEPULCHER_MANAGER, GREAT_SAGES_SEPULCHER_MANAGER,
      JUDGES_SEPULCHER_MANAGER
    )
    add_kill_id(
      HALISHA_ALECTIA, HALISHA_TISHAS, HALISHA_MEKARA, HALISHA_MORIGUL
    )
    add_kill_id(MOB1.keys)
    add_kill_id(MOB2.keys)
    add_kill_id(MOB3.keys)
    register_quest_items(
      SEALED_BOX, GOBLET_OF_ALECTIA, GOBLET_OF_TISHAS, GOBLET_OF_MEKARA,
      GOBLET_OF_MORIGUL, USED_GRAVE_PASS
    )
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && Util.in_range?(1500, npc, pc, false)
      case npc.id
      when HALISHA_ALECTIA
        if !has_quest_items?(pc, GOBLET_OF_ALECTIA) && !has_quest_items?(pc, ANTIQUE_BROOCH)
          give_items(pc, GOBLET_OF_ALECTIA, 1)
        end

        st.set_memo_state_ex(1, 2)
      when HALISHA_TISHAS
        if !has_quest_items?(pc, GOBLET_OF_TISHAS) && !has_quest_items?(pc, ANTIQUE_BROOCH)
          give_items(pc, GOBLET_OF_TISHAS, 1)
        end

        st.set_memo_state_ex(1, 2)
      when HALISHA_MEKARA
        if !has_quest_items?(pc, GOBLET_OF_MEKARA) && !has_quest_items?(pc, ANTIQUE_BROOCH)
          give_items(pc, GOBLET_OF_MEKARA, 1)
        end

        st.set_memo_state_ex(1, 2)
      when HALISHA_MORIGUL
        if !has_quest_items?(pc, GOBLET_OF_MORIGUL) && !has_quest_items?(pc, ANTIQUE_BROOCH)
          give_items(pc, GOBLET_OF_MORIGUL, 1)
        end

        st.set_memo_state_ex(1, 2)
      else
        # automatically added
      end

    end
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    return unless st = get_quest_state(pc, false)

    html = nil
    case event
    when "31453-02.htm", "31453-03.htm", "31453-04.htm", "31453-05.htm",
         "31453-06.htm", "31453-07.htm", "31453-08.htm", "31453-09.htm",
         "31453-10.htm", "31453-11.htm", "31453-16.html", "31453-17.html",
         "31453-18.html", "31453-19.html", "31453-20.html", "31453-21.html",
         "31453-22.html", "31453-23.html", "31453-24.html", "31453-25.html",
         "31453-27.html", "31452-04.html"
      html = event
    when "31453-12.htm"
      st.memo_state = 0
      st.start_quest
      if has_quest_items?(pc, ANTIQUE_BROOCH)
        st.set_cond(2)
      end
      html = event
    when "31453-15.html"
      take_items(pc, -1, {CHAPEL_KEY, USED_GRAVE_PASS})
      st.exit_quest(true, true)
      html = event
    when "31453-28.html"
      if has_quest_items?(pc, GOBLET_OF_ALECTIA, GOBLET_OF_TISHAS, GOBLET_OF_MEKARA, GOBLET_OF_MORIGUL)
        give_items(pc, ANTIQUE_BROOCH, 1)
        st.set_cond(2, true)
        take_items(pc, 1, {GOBLET_OF_ALECTIA, GOBLET_OF_TISHAS, GOBLET_OF_MEKARA, GOBLET_OF_MORIGUL})
        html = event
      end
    when "31454-02.html"
      pc.tele_to_location(ENTER_LOC, 0)
      html = event
    when "31454-04.html"
      memo_state_ex = st.get_memo_state_ex(1)
      if memo_state_ex == 2 || memo_state_ex == 3
        if get_quest_items_count(pc, BROKEN_RELIC_PART) >= 1000
          html = event
        end
      end
    when "6881", "6883", "6885", "6887", "6891", "6893", "6895", "6897", "6899",
         "7580"
      memo_state_ex = st.get_memo_state_ex(1)
      if memo_state_ex == 2 || memo_state_ex == 3
        if get_quest_items_count(pc, BROKEN_RELIC_PART) >= 1000
          give_items(pc, event.to_i, 1)
          take_items(pc, BROKEN_RELIC_PART, 1000)
          html = "31454-05.html"
        end
      end
    when "31454-07.html"
      memo_state_ex = st.get_memo_state_ex(1)
      if memo_state_ex == 2 || memo_state_ex == 3
        if has_quest_items?(pc, SEALED_BOX)
          if Rnd.rand(100) < 100 # TODO (Adry_85): Check random function
            i2 = get_reward(pc)
            html = i2 ? event : "31454-08.html"
          else
            take_items(pc, SEALED_BOX, 1)
            html = "31454-09.html"
          end
        end
      end
    when "EXIT"
      take_items(pc, CHAPEL_KEY, -1)
      pc.tele_to_location(EXIT_LOC, 0)
      return ""
    when "31919-02.html"
      if has_quest_items?(pc, SEALED_BOX)
        if Rnd.rand(100) < 50
          i2 = get_reward(pc)
          html = i2 ? event : "31919-03.html"
        else
          take_items(pc, SEALED_BOX, 1)
          html = "31919-04.html"
        end
      else
        html = "31919-05.html"
      end
    when "ENTER"
      # TODO (Adry_85): Need rework
      FourSepulchersManager.try_entry(npc.not_nil!, pc)
      return ""
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    case npc.id
    when HALISHA_ALECTIA, HALISHA_TISHAS, HALISHA_MEKARA, HALISHA_MORIGUL
      execute_for_each_player(pc, npc, is_summon, true, false)
    else
      st = get_random_party_member_state(pc, -1, 3, npc)
      if st
        npc_id = npc.id
        if MOB1.has_key?(npc_id)
          st.give_item_randomly(npc, SEALED_BOX, 1, 0, MOB1[npc_id], true)
        elsif MOB2.has_key?(npc_id)
          count = Rnd.rand(100) < MOB2[npc.id] ? 2 : 1
          st.give_item_randomly(npc, SEALED_BOX, count, 0, 1.0, true)
        else
          count = Rnd.rand(100) < MOB3[npc.id] ? 5 : 4
          st.give_item_randomly(npc, SEALED_BOX, count, 0, 1.0, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    html = get_no_quest_msg(pc)
    if st.created?
      html = pc.level >= MIN_LEVEL ? "31453-01.htm" : "31453-13.html"
    elsif st.started?
      case npc.id
      when NAMELESS_SPIRIT
        if !has_quest_items?(pc, ANTIQUE_BROOCH)
          if has_quest_items?(pc, GOBLET_OF_ALECTIA, GOBLET_OF_TISHAS, GOBLET_OF_MEKARA, GOBLET_OF_MORIGUL)
            html = "31453-26.html"
          else
            html = "31453-14.html"
          end
        else
          html = "31453-29.html"
        end
      when GHOST_OF_WIGOTH_1
        if !has_quest_items?(pc, ANTIQUE_BROOCH)
          if has_quest_items?(pc, GOBLET_OF_ALECTIA, GOBLET_OF_TISHAS, GOBLET_OF_MEKARA, GOBLET_OF_MORIGUL)
            html = "31452-01.html"
          else
            if get_quest_items_count(pc, GOBLET_OF_ALECTIA, GOBLET_OF_TISHAS, GOBLET_OF_MEKARA, GOBLET_OF_MORIGUL) < 3
              html = "31452-02.html"
            else
              html = "31452-03.html"
            end
          end
        else
          html = "31452-05.html"
        end
      when GHOST_OF_WIGOTH_2
        memo_state_ex = st.get_memo_state_ex(1)
         broken_relic_part_count = get_quest_items_count(pc, BROKEN_RELIC_PART)
        if memo_state_ex == 2
          if has_quest_items?(pc, GOBLET_OF_ALECTIA, GOBLET_OF_TISHAS, GOBLET_OF_MEKARA, GOBLET_OF_MORIGUL)
            if !has_quest_items?(pc, SEALED_BOX)
              html = broken_relic_part_count < 1000 ? "31454-01.html" : "31454-03.html"
            else
              html = broken_relic_part_count < 1000 ? "31454-06.html" : "31454-10.html"
            end

            st.set_memo_state_ex(1, 3)
          else
            if !has_quest_items?(pc, SEALED_BOX)
              html = broken_relic_part_count < 1000 ? "31454-11.html" : "31454-12.html"
            else
              html = broken_relic_part_count < 1000 ? "31454-13.html" : "31454-14.html"
            end

            st.set_memo_state_ex(1, 3)
          end
        elsif memo_state_ex == 3
          if !has_quest_items?(pc, SEALED_BOX)
            html = broken_relic_part_count < 1000 ? "31454-15.html" : "31454-12.html"
          else
            html = broken_relic_part_count < 1000 ? "31454-13.html" : "31454-14.html"
          end

          st.set_memo_state_ex(1, 3)
        end
      when GHOST_CHAMBERLAIN_OF_ELMOREDEN_1
        html = "31919-01.html"
      when CONQUERORS_SEPULCHER_MANAGER
        html = "31921-01.html"
      when EMPERORS_SEPULCHER_MANAGER
        html = "31922-01.html"
      when GREAT_SAGES_SEPULCHER_MANAGER
        html = "31923-01.html"
      when JUDGES_SEPULCHER_MANAGER
        html = "31924-01.html"
      else
        # automatically added
      end

    end

    html
  end

  private def get_reward(pc)
    i2 = false
    case Rnd.rand(5)
    when 0
      i2 = true
      give_adena(pc, 10000, true)
    when 1
      if Rnd.rand(1000) < 848
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 43
          give_items(pc, CORD)
        elsif i1 < 66
          give_items(pc, METALLIC_FIBER)
        elsif i1 < 184
          give_items(pc, MITHRIL_ORE)
        elsif i1 < 250
          give_items(pc, COARSE_BONE_POWDER)
        elsif i1 < 287
          give_items(pc, METALLIC_THREAD)
        elsif i1 < 484
          give_items(pc, ORIHARUKON_ORE)
        elsif i1 < 681
          give_items(pc, COMPOUND_BRAID)
        elsif i1 < 799
          give_items(pc, ADAMANTITE_NUGGET)
        elsif i1 < 902
          give_items(pc, CRAFTED_LEATHER)
        else
          give_items(pc, ASOFE)
        end
      end

      if Rnd.rand(1000) < 323
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 335
          give_items(pc, SYNTETHIC_COKES)
        elsif i1 < 556
          give_items(pc, MOLD_LUBRICANT)
        elsif i1 < 725
          give_items(pc, MITHRIL_ALLOY)
        elsif i1 < 872
          give_items(pc, DURABLE_METAL_PLATE)
        elsif i1 < 962
          give_items(pc, ORIHARUKON)
        elsif i1 < 986
          give_items(pc, MAESTRO_ANVIL_LOCK)
        else
          give_items(pc, MAESTRO_MOLD)
        end
      end
    when 2
      if Rnd.rand(1000) < 847
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 148
          give_items(pc, BRAIDED_HEMP)
        elsif i1 < 175
          give_items(pc, LEATHER)
        elsif i1 < 273
          give_items(pc, COKES)
        elsif i1 < 322
          give_items(pc, STEEL)
        elsif i1 < 357
          give_items(pc, HIGH_GRADE_SUEDE)
        elsif i1 < 554
          give_items(pc, STONE_OF_PURITY)
        elsif i1 < 685
          give_items(pc, STEEL_MOLD)
        elsif i1 < 803
          give_items(pc, METAL_HARDENER)
        elsif i1 < 901
          give_items(pc, MOLD_GLUE)
        else
          give_items(pc, THONS)
        end
      end

      if Rnd.rand(1000) < 251
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 350
          give_items(pc, VARNISH_OF_PURITY)
        elsif i1 < 587
          give_items(pc, ENRIA)
        elsif i1 < 798
          give_items(pc, SILVER_MOLD)
        elsif i1 < 922
          give_items(pc, MOLD_HARDENER)
        elsif i1 < 966
          give_items(pc, BLACKSMITHS_FRAMES)
        elsif i1 < 996
          give_items(pc, ARTISANS_FRAMES)
        else
          give_items(pc, CRAFTSMAN_MOLD)
        end
      end
    when 3
      if Rnd.rand(1000) < 31
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 223
          give_items(pc, ENCHANT_ARMOR_A_GRADE)
        elsif i1 < 893
          give_items(pc, ENCHANT_ARMOR_B_GRADE)
        else
          give_items(pc, ENCHANT_ARMOR_S_GRADE)
        end
      end

      if Rnd.rand(1000) < 5
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 202
          give_items(pc, ENCHANT_WEAPON_A_GRADE)
        elsif i1 < 928
          give_items(pc, ENCHANT_WEAPON_B_GRADE)
        else
          give_items(pc, ENCHANT_WEAPON_S_GRADE)
        end
      end
    when 4
      if Rnd.rand(1000) < 329
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 88
          give_items(pc, SEALED_TATEOSSIAN_EARRING_PART)
        elsif i1 < 185
          give_items(pc, SEALED_TATEOSSIAN_RING_GEM)
        elsif i1 < 238
          give_items(pc, SEALED_TATEOSSIAN_NECKLACE_CHAIN)
        elsif i1 < 262
          give_items(pc, SEALED_IMPERIAL_CRUSADER_BREASTPLATE_PART)
        elsif i1 < 292
          give_items(pc, SEALED_IMPERIAL_CRUSADER_GAITERS_PATTERN)
        elsif i1 < 356
          give_items(pc, SEALED_IMPERIAL_CRUSADER_GAUNTLETS_DESIGN)
        elsif i1 < 420
          give_items(pc, SEALED_IMPERIAL_CRUSADER_BOOTS_DESIGN)
        elsif i1 < 482
          give_items(pc, SEALED_IMPERIAL_CRUSADER_SHIELD_PART)
        elsif i1 < 554
          give_items(pc, SEALED_IMPERIAL_CRUSADER_HELMET_PATTERN)
        elsif i1 < 576
          give_items(pc, SEALED_DRACONIC_LEATHER_ARMOR_PART)
        elsif i1 < 640
          give_items(pc, SEALED_DRACONIC_LEATHER_GLOVES_FABRIC)
        elsif i1 < 704
          give_items(pc, SEALED_DRACONIC_LEATHER_BOOTS_DESIGN)
        elsif i1 < 777
          give_items(pc, SEALED_DRACONIC_LEATHER_HELMET_PATTERN)
        elsif i1 < 799
          give_items(pc, SEALED_MAJOR_ARCANA_ROBE_PART)
        elsif i1 < 863
          give_items(pc, SEALED_MAJOR_ARCANA_GLOVES_FABRIC)
        elsif i1 < 927
          give_items(pc, SEALED_MAJOR_ARCANA_BOOTS_DESIGN)
        else
          give_items(pc, SEALED_MAJOR_ARCANA_CIRCLET_PATTERN)
        end
      end

      if Rnd.rand(1000) < 54
        i2 = true
        i1 = Rnd.rand(1000)
        if i1 < 100
          give_items(pc, FORGOTTEN_BLADE_EDGE)
        elsif i1 < 198
          give_items(pc, BASALT_BATTLEHAMMER_HEAD)
        elsif i1 < 298
          give_items(pc, IMPERIAL_STAFF_HEAD)
        elsif i1 < 398
          give_items(pc, ANGEL_SLAYER_BLADE)
        elsif i1 < 499
          give_items(pc, DRACONIC_BOW_SHAFT)
        elsif i1 < 601
          give_items(pc, DRAGON_HUNTER_AXE_BLADE)
        elsif i1 < 703
          give_items(pc, SAINT_SPEAR_BLADE)
        elsif i1 < 801
          give_items(pc, DEMON_SPLINTER_BLADE)
        elsif i1 < 902
          give_items(pc, HEAVENS_DIVIDER_EDGE)
        else
          give_items(pc, ARCANA_MACE_HEAD)
        end
      end
    else
      # automatically added
    end


    take_items(pc, SEALED_BOX, 1)

    i2
  end
end