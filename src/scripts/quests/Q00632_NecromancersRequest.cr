class Scripts::Q00632_NecromancersRequest < Quest
  # NPC
  private MYSTERIOUS_WIZARD = 31522
  # Items
  private VAMPIRES_HEART = 7542
  private ZOMBIES_BRAIN = 7543
  # Misc
  private MIN_LEVEL = 63
  private REQUIRED_ITEM_COUNT = 200
  private ADENA_REWARD = 120000
  # Monsters
  private BRAIN_MONSTERS = {
    21547 => 0.565, # Corrupted Knight
    21548 => 0.484, # Resurrected Knight
    21549 => 0.585, # Corrupted Guard
    21550 => 0.597, # Corrupted Guard
    21551 => 0.673, # Resurrected Guard
    21552 => 0.637, # Resurrected Guard
    21555 => 0.575, # Slaughter Executioner
    21556 => 0.560, # Slaughter Executioner
    21562 => 0.631, # Guillotine's Ghost
    21571 => 0.758, # Ghost of Rebellion Soldier
    21576 => 0.647, # Ghost of Guillotine
    21577 => 0.625, # Ghost of Guillotine
    21579 => 0.766  # Ghost of Rebellion Leader
  }
  private HEART_MONSTERS = {
    21568 => 0.452, # Devil Bat
    21569 => 0.484, # Devil Bat
    21573 => 0.499, # Atrox
    21582 => 0.522, # Vampire Soldier
    21585 => 0.413, # Vampire Magician
    21586 => 0.496, # Vampire Adept
    21587 => 0.519, # Vampire Warrior
    21588 => 0.428, # Vampire Wizard
    21589 => 0.439, # Vampire Wizard
    21590 => 0.428, # Vampire Magister
    21591 => 0.502, # Vampire Magister
    21592 => 0.370, # Vampire Magister
    21593 => 0.592, # Vampire Warlord
    21594 => 0.554, # Vampire Warlord
    21595 => 0.392  # Vampire Warlord
  }

  def initialize
    super(632, self.class.simple_name, "Necromancer's Request")

    add_start_npc(MYSTERIOUS_WIZARD)
    add_talk_id(MYSTERIOUS_WIZARD)
    add_kill_id(BRAIN_MONSTERS.keys)
    add_kill_id(HEART_MONSTERS.keys)
    register_quest_items(VAMPIRES_HEART, ZOMBIES_BRAIN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31522-104.htm"
      if pc.level >= MIN_LEVEL
        qs.start_quest
        qs.memo_state = 11
        html = event
      end
    when "31522-201.html"
      html = event
    when "31522-202.html"
      if get_quest_items_count(pc, VAMPIRES_HEART) >= REQUIRED_ITEM_COUNT
        take_items(pc, VAMPIRES_HEART, -1)
        give_adena(pc, ADENA_REWARD, true)
        qs.memo_state = 11
        html = event
      else
        html = "31522-203.html"
      end
    when "31522-204.html"
      take_items(pc, VAMPIRES_HEART, -1)
      qs.exit_quest(true, true)
      html = event
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    if qs = get_random_party_member_state(pc, -1, 3, npc)
      if tmp = BRAIN_MONSTERS[npc.id]?
        qs.give_item_randomly(npc, ZOMBIES_BRAIN, 1, 0, tmp, true)
      else
        qs.give_item_randomly(npc, VAMPIRES_HEART, 1, 0, HEART_MONSTERS[npc.id], true)

        if get_quest_items_count(pc, VAMPIRES_HEART) >= REQUIRED_ITEM_COUNT
          qs.set_cond(2)
          qs.memo_state = 12
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "31522-101.htm" : "31522-103.htm"
    elsif qs.started?
      if qs.memo_state?(11)
        html = "31522-106.html"
      elsif qs.memo_state?(12)
        if get_quest_items_count(pc, VAMPIRES_HEART) >= REQUIRED_ITEM_COUNT
          html = "31522-105.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
