class Scripts::Q00286_FabulousFeathers < Quest
  # NPC
  private ERINU = 32164
  # Item
  private COMMANDERS_FEATHER = ItemHolder.new(9746, 80)
  # Monsters
  private MOB_DROP_CHANCES = {
    22251 => 0.748, # Shady Muertos Captain
    22253 => 0.772, # Shady Muertos Warrior
    22254 => 0.772, # Shady Muertos Archer
    22255 => 0.796, # Shady Muertos Commander
    22256 => 0.952  # Shady Muertos Wizard
  }
  # Misc
  private MIN_LVL = 17

  def initialize
    super(286, self.class.simple_name, "Fabulous Feathers")

    add_start_npc(ERINU)
    add_talk_id(ERINU)
    add_kill_id(MOB_DROP_CHANCES.keys)
    register_quest_items(COMMANDERS_FEATHER.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "32164-03.htm"
      qs.start_quest
      html = event
    when "32164-06.html"
      if qs.cond?(2) && has_item?(pc, COMMANDERS_FEATHER)
        take_item(pc, COMMANDERS_FEATHER)
        give_adena(pc, 4160, true)
        qs.exit_quest(true, true)
        html = event
      else
        html = "32164-07.html"
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 1, 3, npc)
      if give_item_randomly(qs.player, npc, COMMANDERS_FEATHER.id, 1, COMMANDERS_FEATHER.count, MOB_DROP_CHANCES[npc.id], true)
        qs.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LVL ? "32164-01.htm" : "32164-02.htm"
    elsif qs.started?
      if qs.cond?(2) && has_item?(pc, COMMANDERS_FEATHER)
        html = "32164-04.html"
      else
        html = "32164-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
