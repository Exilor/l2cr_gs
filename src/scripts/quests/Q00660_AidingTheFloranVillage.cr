class Scripts::Q00660_AidingTheFloranVillage < Quest
  # NPC
  private ALEX = 30291
  private MARIA = 30608
  # Items
  private SCROLL_ENCHANT_WEAPON_D_GRADE = 955
  private SCROLL_ENCHANT_ARMOR_D_GRADE = 956
  private WATCHING_EYES = 8074
  private ROUGHLY_HEWN_ROCK_GOLEM_SHARD = 8075
  private DELU_LIZARDMANS_SCALE = 8076
  # Misc
  private MIN_LEVEL = 30
  private ADENA_REWARD_1 = 13000
  private ADENA_REWARD_2 = 1000
  private ADENA_REWARD_3 = 20000
  private ADENA_REWARD_4 = 2000
  private ADENA_REWARD_5 = 45000
  private ADENA_REWARD_6 = 5000
  private DELU_LIZARDMAN_COMMANDER_DOUBLE_ITEM_CHANCE = 33
  # Monsters
  private DELU_LIZARDMAN_COMMANDER = 21107 # Delu Lizardman Commander

  private MONSTERS = {
    21102 => ItemChanceHolder.new(WATCHING_EYES, 0.500), # Watchman of the Plains
    21106 => ItemChanceHolder.new(WATCHING_EYES, 0.630), # Cursed Seer
    21103 => ItemChanceHolder.new(ROUGHLY_HEWN_ROCK_GOLEM_SHARD, 0.520), # Roughly Hewn Rock Golem
    20781 => ItemChanceHolder.new(DELU_LIZARDMANS_SCALE, 0.650), # Delu Lizardman Shaman
    21104 => ItemChanceHolder.new(DELU_LIZARDMANS_SCALE, 0.650), # Delu Lizardman Supplier
    21105 => ItemChanceHolder.new(DELU_LIZARDMANS_SCALE, 0.750) # Delu Lizardman Special Agent
  }

  def initialize
    super(660, self.class.simple_name, "Aiding the Floran Village")

    add_start_npc(MARIA, ALEX)
    add_talk_id(MARIA, ALEX)
    add_kill_id(MONSTERS.keys)
    add_kill_id(DELU_LIZARDMAN_COMMANDER)
    register_quest_items(
      WATCHING_EYES, ROUGHLY_HEWN_ROCK_GOLEM_SHARD, DELU_LIZARDMANS_SCALE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30608-06.htm"
      if pc.level >= MIN_LEVEL
        qs.start_quest
        html = event
      else
        html = "30608-06a.htm"
      end
    when "30608-02.htm", "30608-03.html", "30291-07.html", "30291-09.html",
         "30291-10.html", "30291-14.html", "30291-18.html"
      html = event
    when "30291-03.htm"
      if pc.level >= MIN_LEVEL
        if qs.created?
          qs.state = State::STARTED
          qs.set_cond(2)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ACCEPT)
        end
        html = event
      else
        html = "30291-02.htm"
      end
    when "30291-06.html"
      count = get_quest_items_count(pc, WATCHING_EYES)
      count &+= get_quest_items_count(pc, ROUGHLY_HEWN_ROCK_GOLEM_SHARD)
      count &+= get_quest_items_count(pc, DELU_LIZARDMANS_SCALE)
      if count > 0
        give_adena(pc, count * 100, true)
        take_items(pc, -1, {WATCHING_EYES, ROUGHLY_HEWN_ROCK_GOLEM_SHARD, DELU_LIZARDMANS_SCALE})
        html = event
      else
        html = "30291-08.html"
      end
    when "30291-08a.html"
      qs.exit_quest(true, true)
      take_items(pc, -1, {WATCHING_EYES, ROUGHLY_HEWN_ROCK_GOLEM_SHARD, DELU_LIZARDMANS_SCALE})
      html = event
    when "30291-12.html"
      count1 = get_quest_items_count(pc, WATCHING_EYES)
      count2 = get_quest_items_count(pc, ROUGHLY_HEWN_ROCK_GOLEM_SHARD)
      count3 = get_quest_items_count(pc, DELU_LIZARDMANS_SCALE)
      count = count1 &+ count2 &+ count3
      if count < 100
        html = "30291-11.html"
      else
        trade_items(pc, 100, count1, count2, count3)

        if Rnd.rand(99) > 50
          give_items(pc, SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
          give_adena(pc, ADENA_REWARD_1, true)
          html = event
        else
          give_adena(pc, ADENA_REWARD_2, true)
          html = "30291-13.html"
        end
      end
    when "30291-16.html"
      count1 = get_quest_items_count(pc, WATCHING_EYES)
      count2 = get_quest_items_count(pc, ROUGHLY_HEWN_ROCK_GOLEM_SHARD)
      count3 = get_quest_items_count(pc, DELU_LIZARDMANS_SCALE)
      count = count1 + count2 + count3
      if count < 200
        html = "30291-15.html"
      else
        trade_items(pc, 200, count1, count2, count3)

        if Rnd.rand(100) >= 50
          if Rnd.rand(2) == 0
            give_items(pc, SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
            give_adena(pc, ADENA_REWARD_3, true)
          else
            give_items(pc, SCROLL_ENCHANT_WEAPON_D_GRADE, 1)
          end
          html = event
        else
          give_adena(pc, ADENA_REWARD_4, true)
          html = "30291-17.html"
        end
      end
    when "30291-20.html"
      count1 = get_quest_items_count(pc, WATCHING_EYES)
      count2 = get_quest_items_count(pc, ROUGHLY_HEWN_ROCK_GOLEM_SHARD)
      count3 = get_quest_items_count(pc, DELU_LIZARDMANS_SCALE)
      count = count1 + count2 + count3
      if count < 500
        html = "30291-19.html"
      else
        trade_items(pc, 500, count1, count2, count3)

        if Rnd.rand(100) >= 50
          give_items(pc, SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
          give_adena(pc, ADENA_REWARD_5, true)
          html = event
        else
          give_adena(pc, ADENA_REWARD_6, true)
          html = "30291-21.html"
        end
      end
    when "30291-22.html"
      count = get_quest_items_count(pc, WATCHING_EYES)
      count &+= get_quest_items_count(pc, ROUGHLY_HEWN_ROCK_GOLEM_SHARD)
      count &+= get_quest_items_count(pc, DELU_LIZARDMANS_SCALE)
      if count <= 0
        html = "30291-23.html"
      else
        give_adena(pc, count * 100, true)
        html = event
      end

      take_items(pc, -1, {WATCHING_EYES, ROUGHLY_HEWN_ROCK_GOLEM_SHARD, DELU_LIZARDMANS_SCALE})
      qs.exit_quest(true, true)
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if qs = get_random_party_member_state(pc, 2, 2, npc)
      if item = MONSTERS[npc.id]?
        give_item_randomly(pc, npc, item.id, item.count, 0, item.chance, true)
      else
        if Rnd.rand(100) < DELU_LIZARDMAN_COMMANDER_DOUBLE_ITEM_CHANCE
          give_items(pc, DELU_LIZARDMANS_SCALE, 2)
        else
          give_items(pc, DELU_LIZARDMANS_SCALE, 1)
        end
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      case npc.id
      when MARIA
        html = pc.level >= MIN_LEVEL ? "30608-01.htm" : "30608-04.html"
      when ALEX
        html = pc.level >= MIN_LEVEL ? "30291-01.htm" : "30291-02.htm"
      end

    elsif qs.started?
      case npc.id
      when MARIA
        html = "30608-05.html"
      when ALEX
        case qs.cond
        when 1
          # Quest started with Maria.
          qs.set_cond(2, true)
          html = "30291-04.html"
        when 2
          html = "30291-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def trade_items(pc, required, count1, count2, count3)
    if count1 < required
      take_items(pc, WATCHING_EYES, count1)
      required &-= count1
    else
      take_items(pc, WATCHING_EYES, required)
      required = 0
    end

    if count2 < required
      take_items(pc, ROUGHLY_HEWN_ROCK_GOLEM_SHARD, count2)
      required &-= count2
    else
      take_items(pc, ROUGHLY_HEWN_ROCK_GOLEM_SHARD, required)
      required = 0
    end

    if count3 < required
      take_items(pc, DELU_LIZARDMANS_SCALE, count3)
    else
      take_items(pc, DELU_LIZARDMANS_SCALE, required)
    end
  end
end
