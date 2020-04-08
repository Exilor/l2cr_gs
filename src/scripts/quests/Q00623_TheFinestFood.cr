class Scripts::Q00623_TheFinestFood < Quest
  # NPCs
  private JEREMY = 31521
  # Monsters
  private THERMAL_BUFFALO = 21315
  private THERMAL_FLAVA = 21316
  private THERMAL_ANTELOPE = 21318
  # Items
  private LEAF_OF_FLAVA = ItemHolder.new(7199, 100)
  private BUFFALO_MEAT = ItemHolder.new(7200, 100)
  private HORN_OF_ANTELOPE = ItemHolder.new(7201, 100)
  # Rewards
  private RING_OF_AURAKYRA = ItemHolder.new(6849, 1)
  private SEALED_SANDDRAGONS_EARING = ItemHolder.new(6847, 1)
  private DRAGON_NECKLACE = ItemHolder.new(6851, 1)
  # Misc
  private MIN_LVL = 71

  private MONSTER_DROPS = {
    THERMAL_BUFFALO => BUFFALO_MEAT,
    THERMAL_FLAVA => LEAF_OF_FLAVA,
    THERMAL_ANTELOPE => HORN_OF_ANTELOPE
  }

  def initialize
    super(623, self.class.simple_name, "The Finest Food")

    add_start_npc(JEREMY)
    add_talk_id(JEREMY)
    add_kill_id(THERMAL_BUFFALO, THERMAL_FLAVA, THERMAL_ANTELOPE)
    register_quest_items(LEAF_OF_FLAVA.id, BUFFALO_MEAT.id, HORN_OF_ANTELOPE.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31521-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "31521-06.html"
      if qs.cond?(2)
        if has_all_items?(pc, true, LEAF_OF_FLAVA, BUFFALO_MEAT, HORN_OF_ANTELOPE)
          random = Rnd.rand(1000)
          if random < 120
            give_adena(pc, 25000, true)
            reward_items(pc, RING_OF_AURAKYRA)
          elsif random < 240
            give_adena(pc, 65000, true)
            reward_items(pc, SEALED_SANDDRAGONS_EARING)
          elsif random < 340
            give_adena(pc, 25000, true)
            reward_items(pc, DRAGON_NECKLACE)
          elsif random < 940
            give_adena(pc, 73000, true)
            add_exp_and_sp(pc, 230000, 18200)
          end
          qs.exit_quest(true, true)
          html = event
        else
          html = "31521-07.html"
        end
      end
    else
      # automatically added
    end


    html
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)

    case npc.id
    when JEREMY
      if qs.created?
        html = talker.level >= MIN_LVL ? "31521-01.htm" : "31521-02.htm"
      elsif qs.started?
        case qs.cond
        when 1
          html = "31521-04.html"
        when 2
          html = "31521-05.html"
        else
          # automatically added
        end

      elsif qs.completed?
        html = get_already_completed_msg(talker)
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(talker)
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, 1, 3, npc)
    holder = MONSTER_DROPS[npc.id]
    if qs && give_item_randomly(qs.player, npc, holder.id, 1, holder.count, 1, true)
      if has_all_items?(qs.player, true, BUFFALO_MEAT, HORN_OF_ANTELOPE, LEAF_OF_FLAVA)
        qs.set_cond(2)
      end
    end

    super
  end
end