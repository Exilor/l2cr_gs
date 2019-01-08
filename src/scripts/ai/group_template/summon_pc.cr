class NpcAI::SummonPc < AbstractNpcAI
  # NPCs
  private PORTA = 20213
  private PERUM = 20221
  # Skill
  private SUMMON_PC = SkillHolder.new(4161, 1)
  # Misc
  private MIN_DISTANCE = 300
  private MIN_DISTANCE_MOST_HATED = 100

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(PORTA, PERUM)
    add_spell_finished_id(PORTA, PERUM)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.variables.get_bool("attacked", false)
      return super
    end

    chance = Rnd.rand(100)
    distance = npc.calculate_distance(attacker, true, false)
    if distance > MIN_DISTANCE
      if chance < 50
        do_summon_pc(npc, attacker)
      end
    elsif distance > MIN_DISTANCE_MOST_HATED
      if npc.most_hated
        if (npc.most_hated == attacker && chance < 50) || chance < 10
          do_summon_pc(npc, attacker)
        end
      end
    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    if skill.id == SUMMON_PC.skill_id && npc.alive?
      if npc.variables.get_bool("attacked", false)
        # pc.tele_to_location(npc)
        # add_attack_desire(npc, pc)
        # npc.variables["attacked"] = false

        # This is my own implementation. It's less visually disruptive for the
        # player and it doesn't mess with aggro lists.
        pc.set_xyz(*npc.xyz)
        pc.stop_move
        pc.broadcast_packet(ValidateLocation.new(pc))
        npc.variables["attacked"] = false
      end
    end

    super
  end

  private def do_summon_pc(npc, attacker)
    if SUMMON_PC.skill.mp_consume2 < npc.current_mp
      if SUMMON_PC.skill.hp_consume < npc.current_hp
        if !npc.skill_disabled?(SUMMON_PC.skill)
          npc.target = attacker
          npc.do_cast(SUMMON_PC.skill)
          npc.variables["attacked"] = true
        end
      end
    end
  end
end
