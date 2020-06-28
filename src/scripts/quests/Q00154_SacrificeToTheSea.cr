class Scripts::Q00154_SacrificeToTheSea < Quest
  # NPCs
  private ROCKSWELL = 30312
  private CRISTEL = 30051
  private ROLLFNAN = 30055
  # Items
  private FOX_FUR = 1032
  private FOX_FUR_YAM = 1033
  private MAIDEN_DOLL = 1034
  # Monsters
  private ELDER_KELTIR = 20544
  private YOUNG_KELTIR = 20545
  private KELTIR = 20481
  # Reward
  private MAGE_EARING = 113
  # Misc
  private MIN_LVL = 2

  def initialize
    super(154, self.class.simple_name, "Sacrifice to the Sea")

    add_start_npc(ROCKSWELL)
    add_talk_id(ROCKSWELL, CRISTEL, ROLLFNAN)
    add_kill_id(ELDER_KELTIR, YOUNG_KELTIR, KELTIR)
    register_quest_items(FOX_FUR, FOX_FUR_YAM, MAIDEN_DOLL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    qs = get_quest_state(pc, false)

    if qs && event == "30312-03.htm"
      qs.start_quest
      event
    end
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when ROCKSWELL
      if qs.created?
        html = pc.level >= MIN_LVL ? "30312-01.htm" : "30312-02.htm"
      elsif qs.started?
        case qs.cond
        when 1
          html = "30312-04.html"
        when 2
          html = "30312-07.html"
        when 3
          html = "30312-05.html"
        when 4
          take_items(pc, MAIDEN_DOLL, -1)
          reward_items(pc, MAGE_EARING, 1)
          add_exp_and_sp(pc, 0, 1000)
          qs.exit_quest(false, true)
          html = "30312-06.html"
        end

      else
        html = get_already_completed_msg(pc)
      end
    when CRISTEL
      case qs.cond
      when 1
        html = "30051-02.html"
      when 2
        take_items(pc, FOX_FUR, -1)
        give_items(pc, FOX_FUR_YAM, 1)
        qs.set_cond(3, true)
        html = "30051-01.html"
      when 3
        html = "30051-03.html"
      when 4
        html = "30051-04.html"
      end

    when ROLLFNAN
      case qs.cond
      when 1, 2
        html = "30055-03.html"
      when 3
        take_items(pc, FOX_FUR_YAM, -1)
        give_items(pc, MAIDEN_DOLL, 1)
        qs.set_cond(4, true)
        html = "30055-01.html"
      when 4
        html = "30055-02.html"
      end

    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, 1, 3, npc)
    if qs && give_item_randomly(qs.player, npc, FOX_FUR, 1, 10, 0.3, true)
      qs.cond = 2
    end

    super
  end
end
