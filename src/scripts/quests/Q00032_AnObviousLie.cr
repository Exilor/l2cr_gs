class Scripts::Q00032_AnObviousLie < Quest
  # NPCs
  private MAXIMILIAN = 30120
  private GENTLER = 30094
  private MIKI_THE_CAT = 31706
  # Monster
  private ALLIGATOR = 20135
  # Items
  private MAP_OF_GENTLER = 7165
  private MEDICINAL_HERB = ItemHolder.new(7166, 20)
  private SPIRIT_ORE = ItemHolder.new(3031, 500)
  private THREAD = ItemHolder.new(1868, 1000)
  private SUEDE = ItemHolder.new(1866, 500)
  # Misc
  private MIN_LVL = 45
  # Reward
  private EARS = {
    "cat" => 6843,     # Cat Ears
    "raccoon" => 7680, # Raccoon ears
    "rabbit" => 7683   # Rabbit ears
  }

  def initialize
    super(32, self.class.simple_name, "An Obvious Lie")

    add_start_npc(MAXIMILIAN)
    add_talk_id(MAXIMILIAN, GENTLER, MIKI_THE_CAT)
    add_kill_id(ALLIGATOR)
    register_quest_items(MAP_OF_GENTLER, MEDICINAL_HERB.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "30120-02.html"
      if qs.created?
        qs.start_quest
        event
      end
    when "30094-02.html"
      if qs.cond?(1)
        give_items(pc, MAP_OF_GENTLER, 1)
        qs.set_cond(2, true)
        event
      end
    when "31706-02.html"
      if qs.cond?(2) && has_quest_items?(pc, MAP_OF_GENTLER)
        take_items(pc, MAP_OF_GENTLER, -1)
        qs.set_cond(3, true)
        event
      end
    when "30094-06.html"
      if qs.cond?(4) && has_item?(pc, MEDICINAL_HERB)
        take_item(pc, MEDICINAL_HERB)
        qs.set_cond(5, true)
        event
      end
    when "30094-09.html"
      if qs.cond?(5) && has_item?(pc, SPIRIT_ORE)
        take_item(pc, SPIRIT_ORE)
        qs.set_cond(6, true)
        event
      end
    when "30094-12.html"
      if qs.cond?(7)
        qs.set_cond(8, true)
        event
      end
    when "30094-15.html"
      event
    when "31706-05.html"
      if qs.cond?(6)
        qs.set_cond(7, true)
        event
      end
    when "cat", "raccoon", "rabbit"
      if qs.cond?(8) && take_all_items(pc, THREAD, SUEDE)
        give_items(pc, EARS[event], 1)
        qs.exit_quest(false, true)
        "30094-16.html"
      else
        "30094-17.html"
      end
    else
      # [automatically added else]
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, 3, 3, npc)
    if qs && give_item_randomly(qs.player, npc, MEDICINAL_HERB.id, 1, MEDICINAL_HERB.count, 1.0, true)
      qs.set_cond(4)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when MAXIMILIAN
      if qs.created?
        html = pc.level >= MIN_LVL ? "30120-01.htm" : "30120-03.htm"
      elsif qs.started?
        if qs.cond?(1)
          html = "30120-04.html"
        end
      else
        html = get_already_completed_msg(pc)
      end
    when GENTLER
      case qs.cond
      when 1
        html = "30094-01.html"
      when 2
        html = "30094-03.html"
      when 4
        html = has_item?(pc, MEDICINAL_HERB) ? "30094-04.html" : "30094-05.html"
      when 5
        html = has_item?(pc, SPIRIT_ORE) ? "30094-07.html" : "30094-08.html"
      when 6
        html = "30094-10.html"
      when 7
        html = "30094-11.html"
      when 8
        if has_all_items?(pc, true, THREAD, SUEDE)
          html = "30094-13.html"
        else
          html = "30094-14.html"
        end
      else
        # [automatically added else]
      end
    when MIKI_THE_CAT
      case qs.cond
      when 2
        if has_quest_items?(pc, MAP_OF_GENTLER)
          html = "31706-01.html"
        end
      when 3..5
        html = "31706-03.html"
      when 6
        html = "31706-04.html"
      when 7
        html = "31706-06.html"
      else
        # [automatically added else]
      end
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
