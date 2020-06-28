class Scripts::Q00311_ExpulsionOfEvilSpirits < Quest
  # NPC
  private CHAIREN = 32655
  # Items
  private PROTECTION_SOULS_PENDANT = 14848
  private SOUL_CORE_CONTAINING_EVIL_SPIRIT = 14881
  private RAGNA_ORCS_AMULET = 14882
  # Misc
  private MIN_LEVEL = 80
  private SOUL_CORE_COUNT = 10
  private RAGNA_ORCS_KILLS_COUNT = 100
  private RAGNA_ORCS_AMULET_COUNT = 10
  # Monsters
  private MONSTERS = {
    22691 => 0.694, # Ragna Orc
    22692 => 0.716, # Ragna Orc Warrior
    22693 => 0.736, # Ragna Orc Hero
    22694 => 0.712, # Ragna Orc Commander
    22695 => 0.698, # Ragna Orc Healer
    22696 => 0.692, # Ragna Orc Shaman
    22697 => 0.640, # Ragna Orc Seer
    22698 => 0.716, # Ragna Orc Archer
    22699 => 0.752, # Ragna Orc Sniper
    22701 => 0.716, # Varangka's Dre Vanul
    22702 => 0.662  # Varangka's Destroyer
  }

  def initialize
    super(311, self.class.simple_name, "Expulsion of Evil Spirits")

    add_start_npc(CHAIREN)
    add_talk_id(CHAIREN)
    add_kill_id(MONSTERS.keys)
    register_quest_items(SOUL_CORE_CONTAINING_EVIL_SPIRIT, RAGNA_ORCS_AMULET)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    if pc.level < MIN_LEVEL
      return
    end

    case event
    when "32655-03.htm", "32655-15.html"
      html = event
    when "32655-04.htm"
      qs.start_quest
      html = event
    when "32655-11.html"
      if get_quest_items_count(pc, SOUL_CORE_CONTAINING_EVIL_SPIRIT) >= SOUL_CORE_COUNT
        take_items(pc, SOUL_CORE_CONTAINING_EVIL_SPIRIT, SOUL_CORE_COUNT)
        give_items(pc, PROTECTION_SOULS_PENDANT, 1)
        html = event
      else
        html = "32655-12.html"
      end
    when "32655-13.html"
      if !has_quest_items?(pc, SOUL_CORE_CONTAINING_EVIL_SPIRIT) && get_quest_items_count(pc, RAGNA_ORCS_AMULET) >= RAGNA_ORCS_AMULET_COUNT
        qs.exit_quest(true, true)
        html = event
      else
        html = "32655-14.html"
      end
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 1, 2, npc)
      count = qs.get_memo_state_ex(1) + 1
      if count >= RAGNA_ORCS_KILLS_COUNT && Rnd.rand(20) < (count % 100) + 1
        qs.set_memo_state_ex(1, 0)
        qs.give_items(SOUL_CORE_CONTAINING_EVIL_SPIRIT, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      else
        qs.set_memo_state_ex(1, count)
      end

      qs.give_item_randomly(npc, RAGNA_ORCS_AMULET, 1, 0, MONSTERS[npc.id], true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "32655-01.htm" : "32655-02.htm"
    elsif qs.started?
      if has_quest_items?(pc, SOUL_CORE_CONTAINING_EVIL_SPIRIT, RAGNA_ORCS_AMULET)
        html = "32655-06.html"
      else
        html = "32655-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
