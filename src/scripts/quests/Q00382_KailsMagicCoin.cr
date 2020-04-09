class Scripts::Q00382_KailsMagicCoin < Quest
  # NPCs
  private VERGARA = 30687
  # Monsters
  private FALLEN_ORC = 21017
  private FALLEN_ORC_ARCHER = 21019
  private FALLEN_ORC_SHAMAN = 21020
  private FALLEN_ORC_CAPTAIN = 21022
  # Items
  private ROYAL_MEMBERSHIP = 5898
  private KAILS_SILVER_BASILISK = 5961
  private KAILS_GOLD_GOLEM = 5962
  private KAILS_BLOOD_DRAGON = 5963
  # Drops
  private ORC_CAPTAIN_DROP_CHANCE = 0.069
  private MONSTER_DROPS = {
    FALLEN_ORC => ItemChanceHolder.new(KAILS_SILVER_BASILISK, 0.073),
    FALLEN_ORC_ARCHER => ItemChanceHolder.new(KAILS_GOLD_GOLEM, 0.075),
    FALLEN_ORC_SHAMAN => ItemChanceHolder.new(KAILS_BLOOD_DRAGON, 0.073)
  }
  # Misc
  private MIN_LVL = 55

  def initialize
    super(382, self.class.simple_name, "Kail's Magic Coin")

    add_start_npc(VERGARA)
    add_talk_id(VERGARA)
    add_kill_id(
      FALLEN_ORC, FALLEN_ORC_ARCHER, FALLEN_ORC_SHAMAN, FALLEN_ORC_CAPTAIN
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30386-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30386-05.htm", "30386-06.htm"
      if qs.started?
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if pc.level >= MIN_LVL && has_quest_items?(pc, ROYAL_MEMBERSHIP)
        html = "30687-02.htm"
      else
        html = "30687-01.htm"
      end
    elsif qs.started?
      html = "30687-04.htm"
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && has_quest_items?(killer, ROYAL_MEMBERSHIP) && Util.in_range?(1500, npc, killer, true)
      if npc.id == FALLEN_ORC_CAPTAIN
        give_item_randomly(
          killer,
          KAILS_SILVER_BASILISK + Rnd.rand(3),
          1,
          0,
          ORC_CAPTAIN_DROP_CHANCE,
          true
        )
      else
        ih = MONSTER_DROPS[npc.id]
        give_item_randomly(killer, ih.id, 1, 0, ih.chance, true)
      end
    end

    super
  end
end
