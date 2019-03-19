class Quests::Q00038_DragonFangs < Quest
  # NPCs
  private IRIS = 30034
  private MAGISTER_ROHMER = 30344
  private GUARD_LUIS = 30386
  # Monsters
  private LIZARDMAN_SENTINEL = 21100
  private LIZARDMAN_SHAMAN = 21101
  private LIZARDMAN_LEADER = 20356
  private LIZARDMAN_SUB_LEADER = 20357
  # Items
  private FEATHER = ItemHolder.new(7173, 100)
  private TOTEM_TOOTH_1ST = 7174
  private TOTEM_TOOTH_2ND = ItemHolder.new(7175, 50)
  private LETTER_1ST = 7176
  private LETTER_2ND = 7177
  # Rewards
  private BONE_HELMET = 45
  private LEATHER_GAUNTLET = 605
  private ASPIS = 627
  private BLUE_BUCKSKIN_BOOTS = 1123
  # Misc
  private MIN_LVL = 19

  def initialize
    super(38, self.class.simple_name, "Dragon Fangs")

    add_start_npc(GUARD_LUIS)
    add_talk_id(GUARD_LUIS, IRIS, MAGISTER_ROHMER)
    add_kill_id(
      LIZARDMAN_SENTINEL, LIZARDMAN_SHAMAN, LIZARDMAN_LEADER,
      LIZARDMAN_SUB_LEADER
    )
    register_quest_items(
      FEATHER.id, TOTEM_TOOTH_1ST, TOTEM_TOOTH_2ND.id, LETTER_1ST, LETTER_2ND
    )
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "30386-03.htm"
      if qs.created?
        qs.start_quest
        htmltext = event
      end
    when "30386-06.html"
      if qs.cond?(2)
        if has_item?(player, FEATHER)
          qs.set_cond(3, true)
          take_item(player, FEATHER)
          give_items(player, TOTEM_TOOTH_1ST, 1)
          htmltext = event
        else
          htmltext = "30386-07.html"
        end
      end

    when "30034-02.html"
      if qs.cond?(3)
        if has_quest_items?(player, TOTEM_TOOTH_1ST)
          qs.set_cond(4, true)
          take_items(player, TOTEM_TOOTH_1ST, 1)
          give_items(player, LETTER_1ST, 1)
          htmltext = event
        else
          htmltext = "30034-03.html"
        end
      end
    when "30034-06.html"
      if qs.cond?(5)
        if has_quest_items?(player, LETTER_2ND)
          qs.set_cond(6, true)
          take_items(player, LETTER_2ND, 1)
          htmltext = event
        else
          htmltext = "30034-07.html"
        end
      end
    when "30034-10.html"
      if qs.cond?(7)
        if has_item?(player, TOTEM_TOOTH_2ND)
          add_exp_and_sp(player, 435117, 23977)
          chance = Rnd.rand(1000)
          if chance < 250
            reward_items(player, BONE_HELMET, 1)
            give_adena(player, 5200, true)
          elsif chance < 500
            reward_items(player, ASPIS, 1)
            give_adena(player, 1500, true)
          elsif chance < 750
            reward_items(player, BLUE_BUCKSKIN_BOOTS, 1)
            give_adena(player, 3200, true)
          elsif chance < 1000
            reward_items(player, LEATHER_GAUNTLET, 1)
            give_adena(player, 3200, true)
          end
          qs.exit_quest(false, true)
          htmltext = event
        else
          htmltext = "30034-11.html"
        end
      end
    when "30344-02.html"
      if qs.cond?(4)
        if has_quest_items?(player, LETTER_1ST)
          qs.set_cond(5, true)
          take_items(player, LETTER_1ST, 1)
          give_items(player, LETTER_2ND, 1)
          htmltext = event
        else
          htmltext = "30344-03.html"
        end
      end
    end

    htmltext
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)

    case npc.id
    when IRIS
      case qs.cond
      when 3
        htmltext = "30034-01.html"
      when 4
        htmltext = "30034-04.html"
      when 5
        htmltext = "30034-05.html"

      when 6
        htmltext = "30034-09.html"
      when 7
        if has_item?(talker, TOTEM_TOOTH_2ND)
          htmltext = "30034-08.html"
        end
      end
    when MAGISTER_ROHMER
      if qs.cond?(4)
        htmltext = "30344-01.html"
      elsif qs.cond?(5)
        htmltext = "30344-04.html"
      end
    when GUARD_LUIS
      if qs.created?
        htmltext = talker.level >= MIN_LVL ? "30386-01.htm" : "30386-02.htm"
      elsif qs.started?
        case qs.cond
        when 1
          htmltext = "30386-05.html"
        when 2
          if has_item?(talker, FEATHER)
            htmltext = "30386-04.html"
          end
        when 3
          htmltext = "30386-08.html"
        end
      elsif qs.completed?
        htmltext = get_already_completed_msg(talker)
      end
    end

    htmltext || get_no_quest_msg(talker)
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when LIZARDMAN_SUB_LEADER, LIZARDMAN_SENTINEL
      qs = get_random_party_member_state(killer, 1, 3, npc)
      if qs && give_item_randomly(qs.player, npc, FEATHER.id, 1, FEATHER.count, 1.0, true)
        qs.set_cond(2)
      end
    when LIZARDMAN_LEADER, LIZARDMAN_SHAMAN
      qs = get_random_party_member_state(killer, 6, 3, npc)
      if qs && give_item_randomly(qs.player, npc, TOTEM_TOOTH_2ND.id, 1, TOTEM_TOOTH_2ND.count, 0.5, true)
        qs.set_cond(7)
      end
    end

    super
  end
end
