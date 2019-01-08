class Quests::Q00294_CovertBusiness < Quest
  # NPC
  private KEEF = 30534
  # Item
  private BAT_FANG = 1491
  # Monsters
  private MONSTER_DROP_CHANCE = {
    20370 => [6, 3, 1, -1],
    20480 => [5, 2, -1]
  }
  # Reward
  private RING_OF_RACCOON = 1508
  # Misc
  private MIN_LVL = 10

  def initialize
    super(294, self.class.simple_name, "Covert Business")

    add_start_npc(KEEF)
    add_talk_id(KEEF)
    add_kill_id(MONSTER_DROP_CHANCE.keys)
    register_quest_items(BAT_FANG)
  end

  def on_adv_event(event, npc, player)
    return unless player
    qs = get_quest_state(player, false)
    if qs && qs.created? && event == "30534-03.htm"
      qs.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.cond?(1) && Util.in_range?(1500, npc, killer, true)
      chance = Rnd.rand(10)
      count = 0
      MONSTER_DROP_CHANCE[npc.id].each do |i|
        count += 1
        if chance > i
          if give_item_randomly(killer, npc, BAT_FANG, count, 100, 1.0, true)
            qs.set_cond(2)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)
    html = get_no_quest_msg(talker)
    if qs.created?
      html = talker.race.dwarf? ? talker.level >= MIN_LVL ? "30534-02.htm" : "30534-01.htm" : "30534-00.htm"
    elsif qs.started?
      if qs.cond?(2)
        if has_quest_items?(talker, RING_OF_RACCOON)
          give_adena(talker, 2400, true)
          html = "30534-06.html"
        else
          give_items(talker, RING_OF_RACCOON, 1)
          html = "30534-05.html"
        end
        add_exp_and_sp(talker, 0, 600)
        qs.exit_quest(true, true)
      else
        html = "30534-04.html"
      end
    end

    html
  end
end
