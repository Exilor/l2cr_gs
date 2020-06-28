class Scripts::Q00625_TheFinestIngredientsPart2 < Quest
  # NPCs
  private JEREMY = 31521
  private YETIS_TABLE = 31542
  # Monster
  private ICICLE_EMPEROR_BUMBALUMP = 25296
  # Required Item
  private SOY_SOURCE_JAR = ItemHolder.new(7205, 1)
  # Quest Items
  private FOOD_FOR_BUMBALUMP = ItemHolder.new(7209, 1)
  private SPECIAL_YETI_MEAT = ItemHolder.new(7210, 1)
  # Rewards
  private GREATER_DYE_OF_STR_1 = ItemHolder.new(4589, 5)
  private GREATER_DYE_OF_STR_2 = ItemHolder.new(4590, 5)
  private GREATER_DYE_OF_CON_1 = ItemHolder.new(4591, 5)
  private GREATER_DYE_OF_CON_2 = ItemHolder.new(4592, 5)
  private GREATER_DYE_OF_DEX_1 = ItemHolder.new(4593, 5)
  private GREATER_DYE_OF_DEX_2 = ItemHolder.new(4594, 5)
  # Location
  private ICICLE_EMPEROR_BUMBALUMP_LOC = Location.new(158240, -121536, -2222)
  # Misc
  private MIN_LVL = 73

  def initialize
    super(625, self.class.simple_name, "The Finest Ingredients - Part 2")

    add_start_npc(JEREMY)
    add_talk_id(JEREMY, YETIS_TABLE)
    add_spawn_id(ICICLE_EMPEROR_BUMBALUMP)
    add_kill_id(ICICLE_EMPEROR_BUMBALUMP)
    register_quest_items(FOOD_FOR_BUMBALUMP.id, SPECIAL_YETI_MEAT.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31521-04.htm"
      if qs.created?
        qs.start_quest
        take_item(pc, SOY_SOURCE_JAR)
        give_items(pc, FOOD_FOR_BUMBALUMP)
        html = event
      end
    when "31521-08.html"
      if qs.cond?(3)
        if has_item?(pc, SPECIAL_YETI_MEAT)
          random = Rnd.rand(1000)
          if random < 167
            reward_items(pc, GREATER_DYE_OF_STR_1)
          elsif random < 334
            reward_items(pc, GREATER_DYE_OF_STR_2)
          elsif random < 501
            reward_items(pc, GREATER_DYE_OF_CON_1)
          elsif random < 668
            reward_items(pc, GREATER_DYE_OF_CON_2)
          elsif random < 835
            reward_items(pc, GREATER_DYE_OF_DEX_1)
          elsif random < 1000
            reward_items(pc, GREATER_DYE_OF_DEX_2)
          end
          qs.exit_quest(false, true)
          html = event
        else
          html = "31521-09.html"
        end
      end
    when "31542-02.html"
      if qs.cond?(1)
        if has_item?(pc, FOOD_FOR_BUMBALUMP)
          if !bumbalump_spawned?
            qs.set_cond(2, true)
            take_item(pc, FOOD_FOR_BUMBALUMP)
            umpaloopa = add_spawn(ICICLE_EMPEROR_BUMBALUMP, ICICLE_EMPEROR_BUMBALUMP_LOC)
            umpaloopa.summoner = pc
            html = event
          else
            html = "31542-03.html"
          end
        else
          html = "31542-04.html"
        end
      end
    when "NPC_TALK"
      if bumbalump_spawned?
        npc = npc.not_nil!
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::OOOH))
      end
    end


    html
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)

    case npc.id
    when JEREMY
      if qs.created?
        if talker.level >= MIN_LVL
          html = has_item?(talker, SOY_SOURCE_JAR) ? "31521-01.htm" : "31521-02.htm"
        else
          html = "31521-03.htm"
        end
      elsif qs.started?
        case qs.cond
        when 1
          html = "31521-05.html"
        when 2
          html = "31521-06.html"
        when 3
          html = "31521-07.html"
        end

      elsif qs.completed?
        html = get_already_completed_msg(talker)
      end
    when YETIS_TABLE
      case qs.cond
      when 1
        if has_item?(talker, FOOD_FOR_BUMBALUMP)
          html = "31542-01.html"
        end
      when 2
        if !bumbalump_spawned?
          umpaloopa = add_spawn(ICICLE_EMPEROR_BUMBALUMP, ICICLE_EMPEROR_BUMBALUMP_LOC)
          umpaloopa.summoner = talker
          html = "31542-02.html"
        else
          html = "31542-03.html"
        end
      when 3
        html = "31542-05.html"
      end

    end


    html || get_no_quest_msg(talker)
  end

  def on_spawn(npc)
    start_quest_timer("NPC_TALK", 1000 * 1200, npc, nil)
    npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::I_SMELL_SOMETHING_DELICIOUS))

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, 1, 2, npc)
    if qs && Util.in_range?(1500, npc, killer, true)
      if npc.summoner == killer
        qs.set_cond(3, true)
        give_items(qs.player, SPECIAL_YETI_MEAT)
      end
    end

    super
  end

  private def bumbalump_spawned?
    !!SpawnTable.find_any(ICICLE_EMPEROR_BUMBALUMP)
  end
end
