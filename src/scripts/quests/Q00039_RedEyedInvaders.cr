class Scripts::Q00039_RedEyedInvaders < Quest
  # NPCs
  private CAPTAIN_BATHIA = 30332
  private GUARD_BABENCO = 30334
  # Monsters
  private MALE_LIZARDMAN = 20919
  private MALE_LIZARDMAN_SCOUT = 20920
  private MALE_LIZARDMAN_GUARD = 20921
  private GIANT_ARANE = 20925
  # Items
  private LIZ_NECKLACE_A = ItemHolder.new(7178, 100)
  private LIZ_NECKLACE_B = ItemHolder.new(7179, 100)
  private LIZ_PERFUME = ItemHolder.new(7180, 30)
  private LIZ_GEM = ItemHolder.new(7181, 30)
  # Rewards
  private GREEN_HIGH_LURE = ItemHolder.new(6521, 60)
  private BABYDUCK_ROD = ItemHolder.new(6529, 1)
  private FISHING_SHOT_NONE = ItemHolder.new(6535, 500)
  # Misc
  private MIN_LVL = 20

  def initialize
    super(39, self.class.simple_name, "Red-eyed Invaders")

    add_start_npc(GUARD_BABENCO)
    add_talk_id(GUARD_BABENCO, CAPTAIN_BATHIA)
    add_kill_id(MALE_LIZARDMAN_GUARD, MALE_LIZARDMAN_SCOUT, MALE_LIZARDMAN, GIANT_ARANE)
    register_quest_items(LIZ_NECKLACE_A.id, LIZ_NECKLACE_B.id, LIZ_PERFUME.id, LIZ_GEM.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30334-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30332-02.html"
      if qs.cond?(1)
        qs.set_cond(2, true)
        html = event
      end
    when "30332-05.html"
      if qs.cond?(3)
        if has_all_items?(pc, true, LIZ_NECKLACE_A, LIZ_NECKLACE_B)
          qs.set_cond(4, true)
          take_all_items(pc, LIZ_NECKLACE_A, LIZ_NECKLACE_B)
          html = event
        else
          html = "30332-06.html"
        end
      end
    when "30332-09.html"
      if qs.cond?(5)
        if has_all_items?(pc, true, LIZ_PERFUME, LIZ_GEM)
          reward_items(pc, GREEN_HIGH_LURE)
          reward_items(pc, BABYDUCK_ROD)
          reward_items(pc, FISHING_SHOT_NONE)
          add_exp_and_sp(pc, 62366, 2783)
          qs.exit_quest(false, true)
          html = event
        else
          html = "30332-10.html"
        end
      end
    else
      # automatically added
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when CAPTAIN_BATHIA
      case qs.cond
      when 1
        html = "30332-01.html"
      when 2
        html = "30332-03.html"
      when 3
        html = "30332-04.html"
      when 4
        html = "30332-07.html"
      when 5
        html = "30332-08.html"
      else
        # automatically added
      end

    when GUARD_BABENCO
      if qs.created?
        html = pc.level >= MIN_LVL ? "30334-01.htm" : "30334-02.htm"
      elsif qs.started? && qs.cond?(1)
        html = "30334-04.html"
      elsif qs.completed?
        html = get_already_completed_msg(pc)
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when MALE_LIZARDMAN
      qs = get_random_party_member_state(killer, 2, 3, npc)
      if qs && give_item_randomly(qs.player, npc, LIZ_NECKLACE_A.id, 1, LIZ_NECKLACE_A.count, 0.5, true)
        if has_item?(qs.player, LIZ_NECKLACE_B)
          qs.set_cond(3)
        end
      end
    when MALE_LIZARDMAN_SCOUT
      if Rnd.bool
        qs = get_random_party_member_state(killer, 2, 3, npc)
        if qs && give_item_randomly(qs.player, npc, LIZ_NECKLACE_A.id, 1, LIZ_NECKLACE_A.count, 0.5, true)
          if has_item?(qs.player, LIZ_NECKLACE_B)
            qs.set_cond(3)
          end
        end
      else
        qs = get_random_party_member_state(killer, 4, 3, npc)
        if qs && give_item_randomly(qs.player, npc, LIZ_PERFUME.id, 1, LIZ_PERFUME.count, 0.25, true)
          if has_item?(qs.player, LIZ_GEM)
            qs.set_cond(5)
          end
        end
      end
    when MALE_LIZARDMAN_GUARD
      if Rnd.bool
        qs = get_random_party_member_state(killer, 2, 3, npc)
        if qs && give_item_randomly(qs.player, npc, LIZ_NECKLACE_B.id, 1, LIZ_NECKLACE_B.count, 0.5, true)
          if has_item?(qs.player, LIZ_NECKLACE_A)
            qs.set_cond(3)
          end
        end
      else
        qs = get_random_party_member_state(killer, 4, 3, npc)
        if qs && give_item_randomly(qs.player, npc, LIZ_PERFUME.id, 1, LIZ_PERFUME.count, 0.3, true)
          if has_item?(qs.player, LIZ_GEM)
            qs.set_cond(5)
          end
        end
      end
    when GIANT_ARANE
      qs = get_random_party_member_state(killer, 4, 3, npc)
      if qs && give_item_randomly(qs.player, npc, LIZ_GEM.id, 1, LIZ_GEM.count, 0.3, true)
        if has_item?(qs.player, LIZ_PERFUME)
          qs.set_cond(5)
        end
      end
    else
      # automatically added
    end


    super
  end
end