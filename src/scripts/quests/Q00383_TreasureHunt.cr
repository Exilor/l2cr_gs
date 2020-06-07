class Scripts::Q00383_TreasureHunt < Quest
  # NPCs
  private ESPEN = 30890
  private PIRATES_CHEST = 31148
  # Items
  private THIEF_KEY = 1661
  private PIRATES_TREASURE_MAP = 5915
  # Misc
  private MIN_LEVEL = 42
  # Rewards
  private SCROLL_ENCHANT_ARMOR_C = ItemHolder.new(952, 1)
  private SCROLL_ENCHANT_ARMOR_D = ItemHolder.new(956, 1)
  private EMERALD = ItemHolder.new(1337, 1)
  private BLUE_ONYX = ItemHolder.new(1338, 2)
  private ONYX = ItemHolder.new(1339, 2)
  private MITHRIL_GLOVES = ItemHolder.new(2450, 1)
  private SAGES_WORN_GLOVES = ItemHolder.new(2451, 1)
  private MOONSTONE = ItemHolder.new(3447, 2)
  private ALEXANDRITE = ItemHolder.new(3450, 1)
  private FIRE_EMERALD = ItemHolder.new(3453, 1)
  private IMPERIAL_DIAMOND = ItemHolder.new(3456, 1)
  private MUSICAL_SCORE_THEME_OF_LOVE = ItemHolder.new(4408, 1)
  private MUSICAL_SCORE_THEME_OF_BATTLE = ItemHolder.new(4409, 1)
  private MUSICAL_SCORE_THEME_OF_CELEBRATION = ItemHolder.new(4418, 1)
  private MUSICAL_SCORE_THEME_OF_COMEDY = ItemHolder.new(4419, 1)
  private DYE_S1C3_C = ItemHolder.new(4481, 1) # Greater Dye of STR <Str+1 Con-3>
  private DYE_S1D3_C = ItemHolder.new(4482, 1) # Greater Dye of STR <Str+1 Dex-3>
  private DYE_C1S3_C = ItemHolder.new(4483, 1) # Greater Dye of CON<Con+1 Str-3>
  private DYE_C1C3_C = ItemHolder.new(4484, 1) # Greater Dye of CON<Con+1 Dex-3>
  private DYE_D1S3_C = ItemHolder.new(4485, 1) # Greater Dye of DEX <Dex+1 Str-3>
  private DYE_D1C3_C = ItemHolder.new(4486, 1) # Greater Dye of DEX <Dex+1 Con-3>
  private DYE_I1M3_C = ItemHolder.new(4487, 1) # Greater Dye of INT <Int+1 Men-3>
  private DYE_I1W3_C = ItemHolder.new(4488, 1) # Greater Dye of INT <Int+1 Wit-3>
  private DYE_M1I3_C = ItemHolder.new(4489, 1) # Greater Dye of MEN <Men+1 Int-3>
  private DYE_M1W3_C = ItemHolder.new(4490, 1) # Greater Dye of MEN <Men+1 Wit-3>
  private DYE_W1I3_C = ItemHolder.new(4491, 1) # Greater Dye of WIT <Wit+1 Int-3>
  private DYE_W1M3_C = ItemHolder.new(4492, 1) # Greater Dye of WIT <Wit+1 Men-3>

  def initialize
    super(383, self.class.simple_name, "Treasure Hunt")

    add_start_npc(ESPEN)
    add_talk_id(ESPEN, PIRATES_CHEST)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30890-04.htm"
      html = event
    when "30890-05.htm"
      if has_quest_items?(pc, PIRATES_TREASURE_MAP)
        give_adena(pc, 1000, false)
        take_items(pc, PIRATES_TREASURE_MAP, 1)
        html = event
      end
    when "30890-06.htm"
      if has_quest_items?(pc, PIRATES_TREASURE_MAP)
        html = event
      else
        html = "30890-12.html"
      end
    when "30890-07.htm"
      if has_quest_items?(pc, PIRATES_TREASURE_MAP)
        qs.start_quest
        take_items(pc, PIRATES_TREASURE_MAP, 1)
        html = event
      end
    when "30890-08.html", "30890-09.html", "30890-10.html"
      if qs.cond?(1)
        html = event
      end
    when "30890-11.html"
      if qs.cond?(1)
        qs.set_cond(2, true)
        html = event
      end
    when "31148-02.html"
      if qs.cond?(2)
        if has_quest_items?(pc, THIEF_KEY)
          take_items(pc, THIEF_KEY, 1)
          qs.exit_quest(true, true)
          html = event

          bonus = 0i64
          random = Rnd.rand(100)

          if random < 5
            reward_items(pc, MITHRIL_GLOVES)
          elsif random < 6
            reward_items(pc, SAGES_WORN_GLOVES)
          elsif random < 18
            reward_items(pc, SCROLL_ENCHANT_ARMOR_D)
          elsif random < 28
            reward_items(pc, SCROLL_ENCHANT_ARMOR_C)
          else
            bonus &+= 500
          end

          random = Rnd.rand(1000)

          if random < 25
            reward_items(pc, DYE_S1C3_C)
          elsif random < 50
            reward_items(pc, DYE_S1D3_C)
          elsif random < 75
            reward_items(pc, DYE_C1S3_C)
          elsif random < 100
            reward_items(pc, DYE_C1C3_C)
          elsif random < 125
            reward_items(pc, DYE_D1S3_C)
          elsif random < 150
            reward_items(pc, DYE_D1C3_C)
          elsif random < 175
            reward_items(pc, DYE_I1M3_C)
          elsif random < 200
            reward_items(pc, DYE_I1W3_C)
          elsif random < 225
            reward_items(pc, DYE_M1I3_C)
          elsif random < 250
            reward_items(pc, DYE_M1W3_C)
          elsif random < 275
            reward_items(pc, DYE_W1I3_C)
          elsif random < 300
            reward_items(pc, DYE_W1M3_C)
          else
            bonus &+= 300
          end

          random = Rnd.rand(100)

          if random < 4
            reward_items(pc, EMERALD)
          elsif random < 8
            reward_items(pc, BLUE_ONYX)
          elsif random < 12
            reward_items(pc, ONYX)
          elsif random < 16
            reward_items(pc, MOONSTONE)
          elsif random < 20
            reward_items(pc, ALEXANDRITE)
          elsif random < 25
            reward_items(pc, FIRE_EMERALD)
          elsif random < 27
            reward_items(pc, IMPERIAL_DIAMOND)
          else
            bonus &+= 500
          end

          random = Rnd.rand(100)

          if random < 20
            reward_items(pc, MUSICAL_SCORE_THEME_OF_LOVE)
          elsif random < 40
            reward_items(pc, MUSICAL_SCORE_THEME_OF_BATTLE)
          elsif random < 60
            reward_items(pc, MUSICAL_SCORE_THEME_OF_CELEBRATION)
          elsif random < 80
            reward_items(pc, MUSICAL_SCORE_THEME_OF_COMEDY)
          else
            bonus &+= 500
          end

          give_adena(pc, bonus, true)
        else
          html = "31148-03.html"
        end
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if pc.level < MIN_LEVEL
        html = "30890-01.html"
      elsif !has_quest_items?(pc, PIRATES_TREASURE_MAP)
        html = "30890-02.html"
      else
        html = "30890-03.htm"
      end
    elsif qs.started?
      if npc.id == ESPEN
        if qs.cond?(1)
          html = "30890-13.html"
        elsif qs.cond?(2)
          html = "30890-14.html"
        end
      else
        if qs.cond?(2)
          html = "31148-01.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
