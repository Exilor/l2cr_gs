class Scripts::Q00344_1000YearsTheEndOfLamentation < Quest
  # NPCs
  private KAIEN = 30623
  private GARVARENTZ = 30704
  private GILMORE = 30754
  private RODEMAI = 30756
  private ORVEN = 30857
  # Items
  private ARTICLES = 4269
  private OLD_KEY = ItemHolder.new(4270, 1)
  private OLD_HILT = ItemHolder.new(4271, 1)
  private TOTEM_NECKLACE = ItemHolder.new(4272, 1)
  private CRUCIFIX = ItemHolder.new(4273, 1)
  # Monsters
  private MONSTER_CHANCES = {
    20236 => 0.58, # Cave Servant
    20238 => 0.75, # Cave Servant Warrior
    20237 => 0.78, # Cave Servant Archer
    20239 => 0.79, # Cave Servant Captain
    20240 => 0.85, # Royal Cave Servant
    20272 => 0.58, # Cave Servant
    20273 => 0.78, # Cave Servant Archer
    20274 => 0.75, # Cave Servant Warrior
    20275 => 0.79, # Cave Servant Captain
    20276 => 0.85  # Royal Cave Servant
  }
  # Rewards
  private ORIHARUKON_ORE = ItemHolder.new(1874, 25)
  private VARNISH_OF_PURITY = ItemHolder.new(1887, 10)
  private SCROLL_EWC = ItemHolder.new(951, 1)
  private RAID_SWORD = ItemHolder.new(133, 1)
  private COKES = ItemHolder.new(1879, 55)
  private RING_OF_AGES = ItemHolder.new(885, 1)
  private LEATHER = ItemHolder.new(1882, 70)
  private COARSE_BONE_POWDER = ItemHolder.new(1881, 50)
  private HEAVY_DOOM_HAMMER = ItemHolder.new(191, 1)
  private STONE_OF_PURITY = ItemHolder.new(1875, 19)
  private SCROLL_EAC = ItemHolder.new(952, 5)
  private DRAKE_LEATHER_BOOTS = ItemHolder.new(2437, 1)
  # Misc
  private MIN_LVL = 48

  def initialize
    super(344, self.class.simple_name, "1000 years, the End of Lamentation")

    add_start_npc(GILMORE)
    add_talk_id(KAIEN, GARVARENTZ, GILMORE, RODEMAI, ORVEN)
    add_kill_id(MONSTER_CHANCES.keys)
    register_quest_items(
      ARTICLES, OLD_KEY.id, OLD_HILT.id, TOTEM_NECKLACE.id, CRUCIFIX.id
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30754-03.htm", "30754-16.html"
      html = event
    when "30754-04.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30754-08.html"
      if qs.cond?(1)
        count = get_quest_items_count(pc, ARTICLES)
        if count < 1
          html = "30754-07.html"
        else
          take_items(pc, ARTICLES, -1)
          if Rnd.rand(1000) >= count
            give_adena(pc, count * 60, true)
            html = event
          else
            qs.set_cond(2, true)
            case Rnd.rand(4)
            when 0
              qs.memo_state = 1
              give_items(pc, OLD_HILT)
            when 1
              qs.memo_state = 2
              give_items(pc, OLD_KEY)
            when 2
              qs.memo_state = 3
              give_items(pc, TOTEM_NECKLACE)
            when 3
              qs.memo_state = 4
              give_items(pc, CRUCIFIX)
            end


            html = "30754-09.html"
          end
        end
      end
    when "30754-17.html"
      if qs.cond?(1)
        html = event
        qs.exit_quest(true, true)
      end
    when "relic_info"
      case qs.memo_state
      when 1
        html = "30754-10.html"
      when 2
        html = "30754-11.html"
      when 3
        html = "30754-12.html"
      when 4
        html = "30754-13.html"
      end

    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when GILMORE
      if qs.created?
        html = pc.level >= MIN_LVL ? "30754-02.htm" : "30754-01.htm"
      elsif qs.started?
        if qs.cond?(1)
          html = has_quest_items?(pc, ARTICLES) ? "30754-06.html" : "30754-05.html"
        elsif has_item?(pc, OLD_KEY) || has_item?(pc, OLD_HILT) || has_item?(pc, TOTEM_NECKLACE) || has_item?(pc, CRUCIFIX)
          html = "30754-14.html"
        else
          qs.set_cond(1)
          html = "30754-15.html"
        end
      else
        html = get_already_completed_msg(pc)
      end
    when KAIEN
      if qs.memo_state == 1
        if has_item?(pc, OLD_HILT)
          take_items(pc, OLD_HILT.id, -1)
          rnd = Rnd.rand(100)
          if rnd <= 52
            reward_items(pc, ORIHARUKON_ORE)
          elsif rnd <= 76
            reward_items(pc, VARNISH_OF_PURITY)
          elsif rnd <= 98
            reward_items(pc, SCROLL_EWC)
          else
            reward_items(pc, RAID_SWORD)
          end
          qs.set_cond(1)
          html = "30623-01.html"
        else
          html = "30623-02.html"
        end
      end
    when RODEMAI
      if qs.memo_state == 2
        if has_item?(pc, OLD_KEY)
          take_items(pc, OLD_KEY.id, -1)
          rnd = Rnd.rand(100)
          if rnd <= 39
            reward_items(pc, COKES)
          elsif rnd <= 89
            reward_items(pc, SCROLL_EWC)
          else
            reward_items(pc, RING_OF_AGES)
          end
          qs.set_cond(1)
          html = "30756-01.html"
        else
          html = "30756-02.html"
        end
      end
    when GARVARENTZ
      if qs.memo_state == 3
        if has_item?(pc, TOTEM_NECKLACE)
          take_items(pc, TOTEM_NECKLACE.id, -1)
          rnd = Rnd.rand(100)
          if rnd <= 47
            reward_items(pc, LEATHER)
          elsif rnd <= 97
            reward_items(pc, COARSE_BONE_POWDER)
          else
            reward_items(pc, HEAVY_DOOM_HAMMER)
          end
          qs.set_cond(1)
          html = "30704-01.html"
        else
          html = "30704-02.html"
        end
      end
    when ORVEN
      if qs.memo_state == 4
        if has_item?(pc, CRUCIFIX)
          take_items(pc, CRUCIFIX.id, -1)
          rnd = Rnd.rand(100)
          if rnd <= 49
            reward_items(pc, STONE_OF_PURITY)
          elsif rnd <= 69
            reward_items(pc, SCROLL_EAC)
          else
            reward_items(pc, DRAKE_LEATHER_BOOTS)
          end
          qs.set_cond(1)
          html = "30857-01.html"
        else
          html = "30857-02.html"
        end
      end
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 1, 3, npc)
      give_item_randomly(qs.player, npc, ARTICLES, 1, 0, MONSTER_CHANCES[npc.id], true)
    end

    super
  end
end
