class NpcAI::HotSprings < AbstractNpcAI
  # NPCs
  private BANDERSNATCHLING = 21314
  private FLAVA = 21316
  private ATROXSPAWN = 21317
  private NEPENTHES = 21319
  private ATROX = 21321
  private BANDERSNATCH = 21322
  # Skills
  private RHEUMATISM = 4551
  private CHOLERA = 4552
  private FLU = 4553
  private MALARIA = 4554
  # Misc
  private DISEASE_CHANCE = 10

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(
      BANDERSNATCHLING, FLAVA, ATROXSPAWN, NEPENTHES, ATROX, BANDERSNATCH
    )
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Rnd.rand(100) < DISEASE_CHANCE
      try_to_infect(npc, attacker, MALARIA)
    end

    if Rnd.rand(100) < DISEASE_CHANCE
      case npc.id
      when BANDERSNATCHLING, ATROX
        try_to_infect(npc, attacker, RHEUMATISM)
      when FLAVA, NEPENTHES
        try_to_infect(npc, attacker, CHOLERA)
      when ATROXSPAWN, BANDERSNATCH
        try_to_infect(npc, attacker, FLU)
      end

      super
    end
  end

  private def try_to_infect(npc, pc, disease_id)
    info = pc.effect_list.get_buff_info_by_skill_id(disease_id)
    skill_lvl = !info ? 1 : info.skill.level < 10 ? info.skill.level + 1 : 10
    skill = SkillData[disease_id, skill_lvl]?

    if skill && !npc.casting_now? && npc.check_do_cast_conditions(skill)
      npc.target = pc
      npc.do_cast skill
    end
  end
end
