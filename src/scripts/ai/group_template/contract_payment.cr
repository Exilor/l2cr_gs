# custom
class Scripts::ContractPayment < AbstractNpcAI
  private NPCS = 14575..14618

  private CONTRACT_PAYMENT_ID = 4140

  def initialize
    super(self.class.simple_name, "ai/group_template")
    NPCS.each { |id| add_summon_spawn_id(id) }
  end

  def on_summon_spawn(summon)
    start_quest_timer(self.class.simple_name, 3000, nil, summon.owner, true)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if smn = get_valid_summon(pc)
      if smn.casting_now?
        # Wait for the next tick
        return
      end

      if pc.effect_list.get_buff_info_by_skill_id(CONTRACT_PAYMENT_ID).nil?
        attack_target = smn.ai.attack_target
        skill = get_skill(smn)
        old_target = smn.target
        smn.target = pc
        smn.do_cast(skill)
        smn.target = old_target
        if attack_target
          smn.set_intention(AI::ATTACK, attack_target)
        end
      end
    else
      cancel_quest_timer(self.class.simple_name, nil, pc)
      pc.stop_skill_effects(true, CONTRACT_PAYMENT_ID)
    end

    nil
  end

  private def get_valid_summon(pc)
    return unless pc.online?
    return unless (smn = pc.summon) && smn.alive?
    return unless (smn.visible? || smn.teleporting?)
    return unless NPCS.includes?(smn.id)
    smn
  end

  private def get_skill(npc)
    skill_lvl =
    case npc.level
    when 0..45  then 1
    when 46..49 then 2
    when 50..53 then 3
    when 54..57 then 4
    when 58, 59 then 5
    when 60, 61 then 6
    when 62, 63 then 7
    when 64, 65 then 8
    when 66, 67 then 9
    when 68..71 then 10
    when 72..75 then 11
    else 12
    end

    SkillData[CONTRACT_PAYMENT_ID, skill_lvl]
  end
end
