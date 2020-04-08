class Scripts::FrightenedRagnaOrc < AbstractNpcAI
  # NPC ID
  private MOB_ID = 18807
  # Chances
  private ADENA = 10000i64
  private CHANCE = 1000
  private ADENA2 = 1000000i64
  private CHANCE2 = 10
  # Skill
  private SKILL = SkillHolder.new(6234)

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(MOB_ID)
    add_kill_id(MOB_ID)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.script_value?(0)
      npc.script_value = 1
      start_quest_timer("say",  (Rnd.rand(5) + 3) * 1000, npc, nil, true)
    elsif npc.hp_percent < 20 && npc.script_value?(1)
      start_quest_timer("reward", 10000, npc, attacker)
      msg = NpcString::WAIT_WAIT_STOP_SAVE_ME_AND_ILL_GIVE_YOU_10000000_ADENA
      broadcast_npc_say(npc, Say2::NPC_ALL, msg)
      npc.script_value = 2
    end

    super
  end

  def on_kill(npc, pc, is_summon)
    if Rnd.bool
      msg = NpcString::UGH_A_CURSE_UPON_YOU
    else
      msg = NpcString::I_REALLY_DIDNT_WANT_TO_FIGHT
    end

    broadcast_npc_say(npc, Say2::NPC_ALL, msg)
    cancel_quest_timer("say", npc, nil)
    cancel_quest_timer("reward", npc, pc)

    super
  end

  def on_adv_event(event, npc, pc)
    case event
    when "say"
      npc = npc.not_nil!
      if npc.dead? || !npc.script_value?(1)
        cancel_quest_timer("say", npc, nil)
        return
      end
      if Rnd.bool
        msg = NpcString::I_DONT_WANT_TO_FIGHT
      else
        msg = NpcString::IS_THIS_REALLY_NECESSARY
      end
      broadcast_npc_say(npc, Say2::NPC_ALL, msg)
    when "reward"
      npc = npc.not_nil!
      pc = pc.not_nil!
      if npc.alive? && npc.script_value?(2)
        if Rnd.rand(100000) < CHANCE2
          if Rnd.bool
            msg = NpcString::TH_THANKS_I_COULD_HAVE_BECOME_GOOD_FRIENDS_WITH_YOU
          else
            msg = NpcString::ILL_GIVE_YOU_10000000_ADENA_LIKE_I_PROMISED_I_MIGHT_BE_AN_ORC_WHO_KEEPS_MY_PROMISES
          end
          broadcast_npc_say(npc, Say2::NPC_ALL, msg)
          npc.script_value = 3
          npc.do_cast(SKILL.skill)
          10.times { npc.drop_item(pc, Inventory::ADENA_ID, ADENA2) }
        elsif Rnd.rand(100000) < CHANCE
          if Rnd.bool
            msg = NpcString::TH_THANKS_I_COULD_HAVE_BECOME_GOOD_FRIENDS_WITH_YOU
          else
            msg = NpcString::SORRY_BUT_THIS_IS_ALL_I_HAVE_GIVE_ME_A_BREAK
          end
          broadcast_npc_say(npc, Say2::NPC_ALL, msg)
          npc.script_value = 3
          npc.do_cast(SKILL.skill)
          10.times { npc.drop_item(pc, Inventory::ADENA_ID, ADENA) }
        else
          if Rnd.bool
            msg = NpcString::THANKS_BUT_THAT_THING_ABOUT_10000000_ADENA_WAS_A_LIE_SEE_YA
          else
            msg = NpcString::YOURE_PRETTY_DUMB_TO_BELIEVE_ME
          end
          broadcast_npc_say(npc, Say2::NPC_ALL, msg)
        end

        start_quest_timer("despawn", 1000, npc, nil)
      end
    when "despawn"
      npc = npc.not_nil!
      npc.set_running
      x = npc.x + Rnd.rand(-800..800)
      y = npc.y + Rnd.rand(-800..800)
      loc = Location.new(x, y, npc.z, npc.heading)
      npc.set_intention(AI::MOVE_TO, loc)
      npc.delete_me
    else
      # automatically added
    end


    nil
  end
end