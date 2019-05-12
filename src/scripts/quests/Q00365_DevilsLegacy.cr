class Scripts::Q00365_DevilsLegacy < Quest
  # NPCs
  private COLLOB = 30092
  private RANDOLF = 30095
  # Item
  private PIRATES_TREASURE_CHEST = 5873
  # Rewards
  private ENCHANT_WEAPON_C = 951
  private ENCHANT_ARMOR_C = 952
  private ENCHANT_WEAPON_D = 955
  private ENCHANT_ARMOR_D = 956
  private THREAD = 1868
  private ANIMAL_BONE = 1872
  private COKES = 1879
  private STEEL = 1880
  private COARSE_BONE_POWDER = 1881
  private LEATHER = 1882
  private CORD = 1884
  # Misc
  private MIN_LEVEL = 39
  # Skill
  private POISON = SkillHolder.new(4035, 2)
  # Mobs
  private MOBS = {
    20836 => 0.47, # pirates_zombie
    20845 => 0.40, # pirates_zombie_captain
    21629 => 0.40, # pirates_zombie_captain_1
    21630 => 0.40  # pirates_zombie_captain_2
  }

  def initialize
    super(365, self.class.simple_name, "Devil's Legacy")

    add_start_npc(RANDOLF)
    add_talk_id(RANDOLF, COLLOB)
    add_kill_id(MOBS.keys)
    register_quest_items(PIRATES_TREASURE_CHEST)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30095-02.htm"
      qs.start_quest
      qs.memo_state = 1
      html = event
    when "30095-05.html"
      qs.exit_quest(true, true)
      html = event
    when "30095-06.html"
      html = event
    when "REWARD"
      if !qs.memo_state?(1)
        html = "30092-04.html"
      elsif !has_quest_items?(pc, PIRATES_TREASURE_CHEST)
        html = "30092-02.html"
      elsif pc.adena < 600
        html = "30092-03.html"
      else
        if rand(100) < 80
          chance = rand(100)
          if chance < 1
            item_id = ENCHANT_WEAPON_D
          elsif chance < 4
            item_id = ENCHANT_ARMOR_D
          elsif chance < 36
            item_id = THREAD
          elsif chance < 68
            item_id = CORD
          else
            item_id = ANIMAL_BONE
          end
          html = "30092-05.html"
        else
          chance = rand(1000)
          if chance < 10
            item_id = ENCHANT_WEAPON_C
          elsif chance < 40
            item_id = ENCHANT_ARMOR_C
          elsif chance < 60
            item_id = ENCHANT_WEAPON_D
          elsif chance < 260
            item_id = ENCHANT_ARMOR_D
          elsif chance < 445
            item_id = COKES
          elsif chance < 630
            item_id = STEEL
          elsif chance < 815
            item_id = LEATHER
          else
            item_id = COARSE_BONE_POWDER
          end
          npc.target = pc
          npc.do_cast(POISON)
          npc.current_mp = npc.max_mp.to_f
          qs.memo_state = 2
          html = "30092-06.html"
        end
        take_items(pc, PIRATES_TREASURE_CHEST, 1)
        take_items(pc, Inventory::ADENA_ID, 600)
        reward_items(pc, item_id, 1)
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if qs = get_random_party_member_state(pc, -1, 3, npc)
      give_item_randomly(
        qs.player, npc, PIRATES_TREASURE_CHEST, 1, 0, MOBS[npc.id], true
      )
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when RANDOLF
      if qs.created?
        html = pc.level >= MIN_LEVEL ? "30095-01.htm" : "30095-03.html"
      elsif qs.started?
        if has_quest_items?(pc, PIRATES_TREASURE_CHEST)
          chest_count = get_quest_items_count(pc, PIRATES_TREASURE_CHEST)
          give_adena(pc, (chest_count * 400) + 19800, true)
          take_items(pc, PIRATES_TREASURE_CHEST, -1)
          html = "30095-04.html"
        else
          html = "30095-07.html"
        end
      end
    when COLLOB
      if qs.started?
        html = qs.memo_state?(1) ? "30092-01.html" : "30092-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
