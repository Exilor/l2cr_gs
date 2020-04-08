class Scripts::Q00633_InTheForgottenVillage < Quest
  # NPC
  private MINA = 31388
  # Items
  private RIB_BONE_OF_A_BLACK_MAGUS = 7544
  private ZOMBIES_LIVER = 7545
  # Misc
  private MIN_LVL = 65
  private RIB_BONE_REQUIRED_COUNT = 200
  # Mobs
  private MOBS_DROP_CHANCES = {
    21553 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.417), # Trampled Man
    21554 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.417), # Trampled Man
    21557 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.394), # Bone Snatcher
    21558 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.394), # Bone Snatcher
    21559 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.436), # Bone Maker
    21560 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.430), # Bone Shaper
    21561 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.538), # Sacrificed Man
    21563 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.436), # Bone Collector
    21564 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.414), # Skull Collector
    21565 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.420), # Bone Animator
    21566 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.460), # Skull Animator
    21567 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.549), # Bone Slayer
    21570 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.508), # Ghost of Betrayer
    21572 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.465), # Bone Sweeper
    21574 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.586), # Bone Grinder
    21575 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.329), # Bone Grinder
    21578 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.649), # Behemoth Zombie
    21580 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.462), # Bone Caster
    21581 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.505), # Bone Puppeteer
    21583 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.475), # Bone Scavenger
    21584 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.475), # Bone Scavenger
    21596 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.543), # Requiem Lord
    21597 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.510), # Requiem Behemoth
    21598 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.572), # Requiem Behemoth
    21599 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.580), # Requiem Priest
    21600 => ItemChanceHolder.new(ZOMBIES_LIVER, 0.561), # Requiem Behemoth
    21601 => ItemChanceHolder.new(RIB_BONE_OF_A_BLACK_MAGUS, 0.677) # Requiem Behemoth
  }

  def initialize
    super(633, self.class.simple_name, "In The Forgotten Village")

    add_start_npc(MINA)
    add_talk_id(MINA)
    add_kill_id(MOBS_DROP_CHANCES.keys)
    register_quest_items(RIB_BONE_OF_A_BLACK_MAGUS, ZOMBIES_LIVER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31388-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "31388-04.html", "31388-05.html", "31388-06.html"
      if qs.started?
        html = event
      end
    when "31388-07.html"
      if qs.cond?(2)
        if get_quest_items_count(pc, RIB_BONE_OF_A_BLACK_MAGUS) >= RIB_BONE_REQUIRED_COUNT
          give_adena(pc, 25000, true)
          add_exp_and_sp(pc, 305235, 0)
          take_items(pc, RIB_BONE_OF_A_BLACK_MAGUS, -1)
          qs.set_cond(1, true)
          html = event
        else
          html = "31388-08.html"
        end
      end
    when "31388-09.html"
      if qs.started?
        qs.exit_quest(true, true)
        html = event
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, npc)
      info = MOBS_DROP_CHANCES[npc.id]
      case info.id
      when RIB_BONE_OF_A_BLACK_MAGUS
        if qs.cond?(1)
          if give_item_randomly(qs.player, npc, RIB_BONE_OF_A_BLACK_MAGUS, 1, RIB_BONE_REQUIRED_COUNT, info.chance, true)
            qs.set_cond(2)
          end
        end
      when ZOMBIES_LIVER
        give_item_randomly(qs.player, npc, ZOMBIES_LIVER, 1, 0, info.chance, true)
      else
        # automatically added
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LVL ? "31388-01.htm" : "31388-02.htm"
    elsif qs.started?
      if get_quest_items_count(pc, RIB_BONE_OF_A_BLACK_MAGUS) >= RIB_BONE_REQUIRED_COUNT
        html = "31388-04.html"
      else
        html = "31388-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end