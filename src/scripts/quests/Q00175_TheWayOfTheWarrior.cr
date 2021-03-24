class Scripts::Q00175_TheWayOfTheWarrior < Quest
  # NPCs
  private PERWAN = 32133
  private KEKROPUS = 32138
  # Items
  private WOLF_TAIL = ItemHolder.new(9807, 5)
  private MUERTOS_CLAW = ItemHolder.new(9808, 10)
  # Message

  # Misc
  private MIN_LEVEL = 10
  # Buff
  private UNSEALED_ALTAR = SkillHolder.new(4549)
  # Rewards
  private WARRIORS_SWORD = 9720
  private SOULSHOTS_NO_GRADE_FOR_ROOKIES = ItemHolder.new(5789, 7000)
  private REWARDS = {
    ItemHolder.new(1060, 100), # Lesser Healing Potion
    ItemHolder.new(4412, 10),  # Echo Crystal - Theme of Battle
    ItemHolder.new(4413, 10),  # Echo Crystal - Theme of Love
    ItemHolder.new(4414, 10),  # Echo Crystal - Theme of Solitude
    ItemHolder.new(4415, 10),  # Echo Crystal - Theme of Feast
    ItemHolder.new(4416, 10)   # Echo Crystal - Theme of Celebration
  }
  # Monsters
  private MOUNTAIN_WEREWOLF = 22235
  private MONSTERS = {
    22236, # Muertos Archer
    22239, # Muertos Guard
    22240, # Muertos Scout
    22242, # Muertos Warrior
    22243, # Muertos Captain
    22245, # Muertos Lieutenant
    22246  # Muertos Commander
  }

  private MESSAGE = ExShowScreenMessage.new(
    NpcString::ACQUISITION_OF_RACE_SPECIFIC_WEAPON_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE,
    2,
    5000
  )

  def initialize
    super(175, self.class.simple_name, "The Way of the Warrior")

    add_start_npc(KEKROPUS)
    add_talk_id(KEKROPUS, PERWAN)
    add_kill_id(MOUNTAIN_WEREWOLF)
    add_kill_id(MONSTERS)
    register_quest_items(WOLF_TAIL.id, MUERTOS_CLAW.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "32138-02.htm"
      html = event
    when "32138-05.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "32138-10.html"
      qs.memo_state = 6
      qs.set_cond(7, true)
      html = event
    when "32138-13.html"
      if has_item?(pc, MUERTOS_CLAW)
        take_item(pc, MUERTOS_CLAW)
        give_adena(pc, 8799, true)
        REWARDS.each { |reward| give_items(pc, reward) }
        Q00175_TheWayOfTheWarrior.give_newbie_reward(pc)
        give_items(pc, WARRIORS_SWORD, 1)
        add_exp_and_sp(pc, 20_739, 1777)
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        html = event
      end
    when "32133-06.html"
      qs.memo_state = 5
      qs.set_cond(6, true)
      npc = npc.not_nil!
      npc.target = pc
      npc.do_cast(UNSEALED_ALTAR.skill)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if npc.id == MOUNTAIN_WEREWOLF
      qs = get_random_party_member_state(pc, 2, 3, npc)
      if qs && give_item_randomly(qs.player, npc, WOLF_TAIL.id, 1, WOLF_TAIL.count, 0.5, true)
        qs.set_cond(3, true)
      end
    else
      qs = get_random_party_member_state(pc, 7, 3, npc)
      if qs && give_item_randomly(qs.player, npc, MUERTOS_CLAW.id, 1, MUERTOS_CLAW.count, 1.0, true)
        qs.set_cond(8, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when KEKROPUS
      if qs.created?
        if !pc.race.kamael?
          html = "32138-04.htm"
        elsif pc.level >= MIN_LEVEL
          html = "32138-01.htm"
        else
          html = "32138-03.htm"
        end
      elsif qs.started?
        case qs.cond
        when 1..3
          html = "32138-06.html"
        when 4
          qs.memo_state = 4
          qs.set_cond(5, true)
          html = "32138-07.html"
        when 5
          html = "32138-08.html"
        when 6
          html = "32138-09.html"
        when 7
          html = "32138-11.html"
        when 8
          if has_item?(pc, MUERTOS_CLAW)
            html = "32138-12.html"
          end
        end
      elsif qs.completed?
        html = get_already_completed_msg(pc)
      end
    when PERWAN
      case qs.cond
      when 1
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = "32133-01.html"
      when 2
        html = "32133-02.html"
      when 3
        if has_item?(pc, WOLF_TAIL)
          take_item(pc, WOLF_TAIL)
          qs.memo_state = 3
          qs.set_cond(4, true)
          html = "32133-03.html"
        end
      when 4
        html = "32133-04.html"
      when 5
        html = "32133-05.html"
      when 6
        html = "32133-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  def self.give_newbie_reward(pc : L2PcInstance)
    vars = pc.variables
    if pc.level < 25 && !vars.get_bool("NEWBIE_SHOTS", false)
      play_sound(pc, Voice::TUTORIAL_VOICE_026_1000)
      give_items(pc, SOULSHOTS_NO_GRADE_FOR_ROOKIES)
      vars["NEWBIE_SHOTS"] = true
    end
    if vars["GUIDE_MISSION"]?.nil?
      vars["GUIDE_MISSION"] = 100_000
      pc.send_packet(MESSAGE)
    elsif (vars.get_i32("GUIDE_MISSION") % 100_0000) / 100_000 != 1
      vars["GUIDE_MISSION"] = vars.get_i32("GUIDE_MISSION") + 100_000
      pc.send_packet(MESSAGE)
    end
  end
end
