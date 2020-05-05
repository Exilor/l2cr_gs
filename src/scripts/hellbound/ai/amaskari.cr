class Scripts::Amaskari < AbstractNpcAI
  # NPCs
  private AMASKARI = 22449
  private AMASKARI_PRISONER = 22450
  # Skills
  # private static SkillHolder INVINCIBILITY = SkillHolder.new(5417)
  private BUFF_ID = 4632
  private BUFF = {
    SkillHolder.new(BUFF_ID, 1),
    SkillHolder.new(BUFF_ID, 2),
    SkillHolder.new(BUFF_ID, 3)
  }
  # Misc
  private AMASKARI_NPCSTRING_ID = {
    NpcString::ILL_MAKE_EVERYONE_FEEL_THE_SAME_SUFFERING_AS_ME,
    NpcString::HA_HA_YES_DIE_SLOWLY_WRITHING_IN_PAIN_AND_AGONY,
    NpcString::MORE_NEED_MORE_SEVERE_PAIN,
    NpcString::SOMETHING_IS_BURNING_INSIDE_MY_BODY
  }
  private MINIONS_NPCSTRING_ID = {
    NpcString::AHH_MY_LIFE_IS_BEING_DRAINED_OUT,
    NpcString::THANK_YOU_FOR_SAVING_ME,
    NpcString::IT_WILL_KILL_EVERYONE,
    NpcString::EEEK_I_FEEL_SICKYOW
  }

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_kill_id(AMASKARI, AMASKARI_PRISONER)
    add_attack_id(AMASKARI)
    add_spawn_id(AMASKARI_PRISONER)
  end

  def on_adv_event(event, npc, player)
    if event.casecmp?("stop_toggle")
      unless npc.is_a?(L2MonsterInstance)
        raise "#{npc} should be a L2MonsterInstance"
      end
      broadcast_npc_say(npc, Say2::NPC_ALL, AMASKARI_NPCSTRING_ID[2])
      npc.clear_aggro_list
      npc.intention = AI::ACTIVE
      npc.invul = false
      # npc.do_cast(INVINCIBILITY)
    elsif event.casecmp?("onspawn_msg") && npc && npc.alive?
      if Rnd.rand(100) > 20
        broadcast_npc_say(npc, Say2::NPC_ALL, MINIONS_NPCSTRING_ID[2])
      elsif Rnd.rand(100) > 40
        broadcast_npc_say(npc, Say2::NPC_ALL, MINIONS_NPCSTRING_ID[3])
      end
      start_quest_timer("onspawn_msg", (Rnd.rand(8) + 1) * 30000, npc, nil)
    end

    nil
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if npc.id == AMASKARI && Rnd.rand(1000) < 25
      broadcast_npc_say(npc, Say2::NPC_ALL, AMASKARI_NPCSTRING_ID[0])
      npc.as(L2MonsterInstance).minion_list.spawned_minions.each do |minion|
        if minion && minion.alive? && Rnd.rand(10) == 0
          broadcast_npc_say(minion, Say2::NPC_ALL, MINIONS_NPCSTRING_ID[0])
          minion.current_hp -= minion.current_hp / 5
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == AMASKARI_PRISONER
      master = npc.as(L2MonsterInstance).leader?
      if master && master.alive?
        broadcast_npc_say(master, Say2::NPC_ALL, AMASKARI_NPCSTRING_ID[1])
        info = master.effect_list.get_buff_info_by_skill_id(BUFF_ID)
        if info && info.skill.abnormal_lvl == 3 && master.invul?
          master.current_hp += master.current_hp / 5
        else
          master.clear_aggro_list
          master.set_intention(AI::ACTIVE)
          if info.nil?
            master.do_cast(BUFF[0])
          elsif info.skill.abnormal_lvl < 3
            master.do_cast(BUFF[info.skill.abnormal_lvl])
          else
            broadcast_npc_say(master, Say2::NPC_ALL, AMASKARI_NPCSTRING_ID[3])
            # master.do_cast(INVINCIBILITY)
            master.invul = true
            start_quest_timer("stop_toggle", 10000, master, nil)
          end
        end
      end
    elsif npc.id == AMASKARI
      npc.as(L2MonsterInstance).minion_list.spawned_minions.each do |minion|
        if minion.alive?
          if Rnd.rand(1000) > 300
            broadcast_npc_say(minion, Say2::NPC_ALL, MINIONS_NPCSTRING_ID[1])
          end
          HellboundEngine.instance.update_trust(30, true)
          minion.delete_me
        end
      end
    end

    super
  end

  def on_spawn(npc)
    start_quest_timer("onspawn_msg", (Rnd.rand(3) + 1) * 30000, npc, nil)
    return super
  end
end
