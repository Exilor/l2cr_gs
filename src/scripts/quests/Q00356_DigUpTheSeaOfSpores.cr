class Scripts::Q00356_DigUpTheSeaOfSpores < Quest
  # NPC
  private GAUEN = 30717
  # Items
  private CARNIVORE_SPORE = 5865
  private HERBIVOROUS_SPORE = 5866
  # Misc
  private MIN_LEVEL = 43
  # Monsters
  private ROTTING_TREE = 20558
  private SPORE_ZOMBIE = 20562
  private MONSTER_DROP_CHANCES = {
    ROTTING_TREE => 0.73,
    SPORE_ZOMBIE => 0.94
  }

  def initialize
    super(356, self.class.simple_name, "Dig Up the Sea of Spores!")

    add_start_npc(GAUEN)
    add_talk_id(GAUEN)
    add_kill_id(ROTTING_TREE, SPORE_ZOMBIE)
    register_quest_items(HERBIVOROUS_SPORE, CARNIVORE_SPORE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30717-02.htm", "30717-03.htm", "30717-04.htm", "30717-10.html",
         "30717-18.html"
      html = event
    when "30717-05.htm"
      qs.start_quest
      html = event
    when "30717-09.html"
      add_exp_and_sp(pc, 31850, 0)
      take_items(pc, CARNIVORE_SPORE, -1)
      take_items(pc, HERBIVOROUS_SPORE, -1)
      html = event
    when "30717-11.html"
      qs.exit_quest(true, true)
      html = event
    when "30717-14.html"
      add_exp_and_sp(pc, 45500, 2600)
      qs.exit_quest(true, true)
      html = event
    when "FINISH"
      value = rand(100)
      adena = 0
      if value < 20
        adena = 44000
        html = "30717-15.html"
      elsif value < 70
        adena = 20950
        html = "30717-16.html"
      else
        adena = 10400
        html = "30717-17.html"
      end
      give_adena(pc, adena.to_i64, true)
      qs.exit_quest(true, true)
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    unless qs = get_quest_state(killer, false)
      return
    end

    unless Util.in_range?(1500, npc, killer, true)
      return
    end

    if npc.id == ROTTING_TREE
      drop_item = HERBIVOROUS_SPORE
    else
      drop_item = CARNIVORE_SPORE
    end

    if drop_item == HERBIVOROUS_SPORE
      other_item = CARNIVORE_SPORE
    else
      other_item = HERBIVOROUS_SPORE
    end

    if give_item_randomly(qs.player, npc, drop_item, 1, 50, MONSTER_DROP_CHANCES[npc.id], true)
      if get_quest_items_count(killer, other_item) >= 50
        qs.set_cond(3)
      else
        qs.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "30717-01.htm" : "30717-06.htm"
    elsif qs.started?
      all_herb_spores = get_quest_items_count(pc, HERBIVOROUS_SPORE) >= 50
      all_carn_spores = get_quest_items_count(pc, CARNIVORE_SPORE) >= 50

      if all_herb_spores && all_carn_spores
        html = "30717-13.html"
      elsif all_carn_spores
        html = "30717-12.html"
      elsif all_herb_spores
        html = "30717-08.html"
      else
        html = "30717-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
