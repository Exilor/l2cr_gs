class Scripts::SinEater < AbstractNpcAI
  # NPCs
  private SIN_EATER = 12564

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_summon_spawn_id(SIN_EATER)
    add_summon_talk_id(SIN_EATER)
  end

  def on_adv_event(event, npc, player)
    if event == "TALK" && player && (smn = player.summon)
      if Rnd.rand(100) < 30
        random = Rnd.rand(100)

        if random < 20
          broadcast_summon_say(smn, NpcString::YAWWWWN_ITS_SO_BORING_HERE_WE_SHOULD_GO_AND_FIND_SOME_ACTION)
        elsif random < 40
          broadcast_summon_say(smn, NpcString::HEY_IF_YOU_CONTINUE_TO_WASTE_TIME_YOU_WILL_NEVER_FINISH_YOUR_PENANCE)
        elsif random < 60
          broadcast_summon_say(smn, NpcString::I_KNOW_YOU_DONT_LIKE_ME_THE_FEELING_IS_MUTUAL)
        elsif random < 80
          broadcast_summon_say(smn, NpcString::I_NEED_A_DRINK)
        else
          broadcast_summon_say(smn, NpcString::OH_THIS_IS_DRAGGING_ON_TOO_LONG_AT_THIS_RATE_I_WONT_MAKE_IT_HOME_BEFORE_THE_SEVEN_SEALS_ARE_BROKEN)
        end
      end

      start_quest_timer("TALK", 60000, nil, player)
    end

    super
  end

  @[Register(event: ON_CREATURE_KILL, register: NPC, id: 12564)]
  def on_creature_kill(event : OnCreatureKill)
    random = Rnd.rand(100)
    summon = event.target.as(L2Summon)

    if random < 30
      broadcast_summon_say(summon, NpcString::OH_THIS_IS_JUST_GREAT_WHAT_ARE_YOU_GOING_TO_DO_NOW)
    elsif random < 70
      broadcast_summon_say(summon, NpcString::YOU_INCONSIDERATE_MORON_CANT_YOU_EVEN_TAKE_CARE_OF_LITTLE_OLD_ME)
    else
      broadcast_summon_say(summon, NpcString::OH_NO_THE_MAN_WHO_EATS_ONES_SINS_HAS_DIED_PENITENCE_IS_FURTHER_AWAY)
    end
  end

  @[Register(event: ON_CREATURE_ATTACKED, register: NPC, id: 12564)]
  def on_creature_attacked(event : OnCreatureAttacked)
    if Rnd.rand(100) < 30
      random = Rnd.rand(100)
      summon = event.target.as(L2Summon)

      if random < 35
        broadcast_summon_say(summon, NpcString::OH_THAT_SMARTS)
      elsif random < 70
        broadcast_summon_say(summon, NpcString::HEY_MASTER_PAY_ATTENTION_IM_DYING_OVER_HERE)
      else
        broadcast_summon_say(summon, NpcString::WHAT_HAVE_I_DONE_TO_DESERVE_THIS)
      end
    end
  end

  def on_summon_spawn(summon)
    broadcast_summon_say(summon, Rnd.bool ? NpcString::HEY_IT_SEEMS_LIKE_YOU_NEED_MY_HELP_DOESNT_IT : NpcString::ALMOST_GOT_IT_OUCH_STOP_DAMN_THESE_BLOODY_MANACLES)
    start_quest_timer("TALK", 60000, nil, summon.owner)
  end

  def on_summon_talk(summon)
    if Rnd.rand(100) < 10
      random = Rnd.rand(100)

      if random < 25
        broadcast_summon_say(summon, NpcString::USING_A_SPECIAL_SKILL_HERE_COULD_TRIGGER_A_BLOODBATH)
      elsif random < 50
        broadcast_summon_say(summon, NpcString::HEY_WHAT_DO_YOU_EXPECT_OF_ME)
      elsif random < 75
        broadcast_summon_say(summon, NpcString::UGGGGGH_PUSH_ITS_NOT_COMING_OUT)
      else
        broadcast_summon_say(summon, NpcString::AH_I_MISSED_THE_MARK)
      end
    end
  end

  private def broadcast_summon_say(summon, npc_string)
    summon.broadcast_packet(
      NpcSay.new(
        summon.l2id, Say2::NPC_ALL, summon.id, npc_string
      )
    )
  end
end
