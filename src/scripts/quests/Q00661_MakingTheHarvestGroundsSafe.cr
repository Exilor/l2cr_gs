class Scripts::Q00661_MakingTheHarvestGroundsSafe < Quest
  # NPC
  private NORMAN = 30210
  # Items
  private BIG_HORNET_STING = 8283
  private CLOUD_GEM = 8284
  private YOUNG_ARANEID_CLAW = 8285
  # Monsters
  private MONSTER_CHANCES = {
    21095 => ItemChanceHolder.new(BIG_HORNET_STING, 0.508), # Giant Poison Bee
    21096 => ItemChanceHolder.new(CLOUD_GEM, 0.5), # Cloudy Beast
    21097 => ItemChanceHolder.new(YOUNG_ARANEID_CLAW, 0.516) # Young Araneid
  }
  # Misc
  private MIN_LVL = 21

  def initialize
    super(661, self.class.simple_name, "Making the Harvest Grounds Safe")

    add_start_npc(NORMAN)
    add_talk_id(NORMAN)
    add_kill_id(MONSTER_CHANCES.keys)
    register_quest_items(BIG_HORNET_STING, CLOUD_GEM, YOUNG_ARANEID_CLAW)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "30210-01.htm", "30210-02.htm", "30210-04.html", "30210-06.html"
      html = event
    when "30210-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30210-08.html"
      sting_count = get_quest_items_count(pc, BIG_HORNET_STING)
      gem_count = get_quest_items_count(pc, CLOUD_GEM)
      claw_count = get_quest_items_count(pc, YOUNG_ARANEID_CLAW)
      reward = (57 &* sting_count) &+ (56 &* gem_count) &+ (60 &* claw_count)
      if sting_count &+ gem_count &+ claw_count >= 10
        reward &+= 5773
      end
      take_items(pc, BIG_HORNET_STING, -1)
      take_items(pc, CLOUD_GEM, -1)
      take_items(pc, YOUNG_ARANEID_CLAW, -1)
      give_adena(pc, reward, true)
      html = event
    when "30210-09.html"
      qs.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "30210-01.htm" : "30210-02.htm"
    when State::STARTED
      if has_quest_items?(pc, BIG_HORNET_STING, CLOUD_GEM, YOUNG_ARANEID_CLAW)
        html = "30210-04.html"
      else
        html = "30210-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, npc)
      item = MONSTER_CHANCES[npc.id]
      give_item_randomly(qs.player, npc, item.id, item.count, 0, item.chance, true)
    end

    super
  end
end
