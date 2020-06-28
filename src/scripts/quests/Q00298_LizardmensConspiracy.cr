class Scripts::Q00298_LizardmensConspiracy < Quest
  # NPCs
  private GUARD_PRAGA = 30333
  private MAGISTER_ROHMER = 30344
  # Items
  private PATROLS_REPORT = 7182
  private SHINING_GEM = 7183
  private SHINING_RED_GEM = 7184
  # Monsters
  private MONSTERS = {
    20922 => ItemChanceHolder.new(SHINING_GEM, 0.49, 1),
    20924 => ItemChanceHolder.new(SHINING_GEM, 0.75, 1),
    20926 => ItemChanceHolder.new(SHINING_RED_GEM, 0.54, 1),
    20927 => ItemChanceHolder.new(SHINING_RED_GEM, 0.54, 1),
    20922 => ItemChanceHolder.new(SHINING_GEM, 0.70, 1)
  }
  # Misc
  private MIN_LVL = 25

  def initialize
    super(298, self.class.simple_name, "Lizardmen's Conspiracy")

    add_start_npc(GUARD_PRAGA)
    add_talk_id(GUARD_PRAGA, MAGISTER_ROHMER)
    add_kill_id(MONSTERS.keys)
    register_quest_items(PATROLS_REPORT, SHINING_GEM, SHINING_RED_GEM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30333-03.htm"
      if qs.created?
        qs.start_quest
        give_items(pc, PATROLS_REPORT, 1)
        html = event
      end
    when "30344-04.html"
      if qs.cond?(1) && has_quest_items?(pc, PATROLS_REPORT)
        take_items(pc, PATROLS_REPORT, -1)
        qs.set_cond(2, true)
        html = event
      end
    when "30344-06.html"
      if qs.started?
        if qs.cond?(3)
          add_exp_and_sp(pc, 0, 42000)
          qs.exit_quest(true, true)
          html = event
        else
          html = "30344-07.html"
        end
      end
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 2, 3, npc)
      item = MONSTERS[npc.id]
      if give_item_randomly(qs.player, npc, item.id, item.count, 50, item.chance, true)
        if get_quest_items_count(qs.player, SHINING_GEM) >= 50
          if get_quest_items_count(qs.player, SHINING_RED_GEM) >= 50
            qs.set_cond(3, true)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? && npc.id == GUARD_PRAGA
      html = pc.level >= MIN_LVL ? "30333-01.htm" : "30333-02.htm"
    elsif qs.started?
      if npc.id == GUARD_PRAGA && has_quest_items?(pc, PATROLS_REPORT)
        html = "30333-04.html"
      elsif npc.id == MAGISTER_ROHMER
        case qs.cond
        when 1
          html = "30344-01.html"
        when 2
          html = "30344-02.html"
        when 3
          html = "30344-03.html"
        end

      end
    end

    html || get_no_quest_msg(pc)
  end
end
