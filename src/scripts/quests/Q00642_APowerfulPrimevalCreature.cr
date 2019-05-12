class Scripts::Q00642_APowerfulPrimevalCreature < Quest
  # NPC
  private DINN = 32105
  # Items
  private DINOSAUR_TISSUE = 8774
  private DINOSAUR_EGG = 8775
  # Misc
  private MIN_LEVEL = 75
  # Mobs
  private ANCIENT_EGG = 18344

  private MOBS_TISSUE = {
    22196 => 0.309, # Velociraptor
    22197 => 0.309, # Velociraptor
    22198 => 0.309, # Velociraptor
    22199 => 0.309, # Pterosaur
    22215 => 0.988, # Tyrannosaurus
    22216 => 0.988, # Tyrannosaurus
    22217 => 0.988, # Tyrannosaurus
    22218 => 0.309, # Velociraptor
    22223 => 0.309  # Velociraptor
  }

  def initialize
    super(642, self.class.simple_name, "A Powerful Primeval Creature")

    add_start_npc(DINN)
    add_talk_id(DINN)
    add_kill_id(ANCIENT_EGG)
    add_kill_id(MOBS_TISSUE.keys)
    register_quest_items(DINOSAUR_TISSUE, DINOSAUR_EGG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "32105-05.html"
      qs.start_quest
    when "32105-06.htm"
      qs.exit_quest(true)
    when "32105-09.html"
      if has_quest_items?(pc, DINOSAUR_TISSUE)
        give_adena(pc, 5000 * get_quest_items_count(pc, DINOSAUR_TISSUE), true)
        take_items(pc, DINOSAUR_TISSUE, -1)
      else
        html = "32105-14.html"
      end
    when "exit"
      if has_quest_items?(pc, DINOSAUR_TISSUE)
        give_adena(pc, 5000 * get_quest_items_count(pc, DINOSAUR_TISSUE), true)
        qs.exit_quest(true, true)
        html = "32105-12.html"
      else
        qs.exit_quest(true, true)
        html = "32105-13.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    unless qs = get_random_party_member_state(killer, -1, 3, npc)
      return
    end

    npc_id = npc.id

    if tmp = MOBS_TISSUE[npc_id]?
      give_item_randomly(qs.player, npc, DINOSAUR_TISSUE, 1, 0, tmp, true)
    else
      give_item_randomly(qs.player, npc, DINOSAUR_EGG, 1, 0, 1.0, true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level < MIN_LEVEL ? "32105-01.htm" : "32105-02.htm"
    elsif qs.started?
      if has_at_least_one_quest_item?(pc, DINOSAUR_TISSUE, DINOSAUR_EGG)
        html = "32105-08.html"
      else
        html = "32105-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
