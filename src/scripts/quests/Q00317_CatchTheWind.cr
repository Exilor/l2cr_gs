class Scripts::Q00317_CatchTheWind < Quest
  # NPC
  private RIZRAELL = 30361
  # Item
  private WIND_SHARD = 1078
  # Misc
  private MIN_LEVEL = 18
  private DROP_CHANCE = 0.5
  # Monsters
  private MONSTERS = {
    20036, # Lirein
    20044  # Lirein Elder
  }

  def initialize
    super(317, self.class.simple_name, "Catch The Wind")

    add_start_npc(RIZRAELL)
    add_talk_id(RIZRAELL)
    add_kill_id(MONSTERS)
    register_quest_items(WIND_SHARD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "30361-04.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30361-08.html", "30361-09.html"
      shard_count = get_quest_items_count(pc, WIND_SHARD)
      if shard_count > 0
        adena = (shard_count * 40) + (shard_count >= 10 ? 2988 : 0)
        give_adena(pc, adena, true)
        take_items(pc, WIND_SHARD, -1)
      end

      if event == "30361-08.html"
        qs.exit_quest(true, true)
      end

      html = event
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, npc)
      give_item_randomly(qs.player, npc, WIND_SHARD, 1, 0, DROP_CHANCE, true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "30361-03.htm" : "30361-02.htm"
    elsif qs.started?
      if has_quest_items?(pc, WIND_SHARD)
        html = "30361-07.html"
      else
        html = "30361-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end