class Scripts::DustRider < AbstractNpcAI
  private DUST_RIDER = 25719
  # Skills
  private NPC_HASTE_LVL_3 = SkillHolder.new(6914, 3)
  # Variables
  private CAST_FLAG = "CAST_FLAG"
  # Misc
  private MAX_CHASE_DIST = 2500
  private MIN_HP_PERCENTAGE = 30

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_attack_id(DUST_RIDER)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Util.calculate_distance(npc, npc.spawn, false, false) > MAX_CHASE_DIST
      npc.tele_to_location(*npc.spawn.xyz)
    end

    if !npc.variables.get_bool(CAST_FLAG, false) && npc.hp_percent < MIN_HP_PERCENTAGE
      npc.variables[CAST_FLAG] = true
      add_skill_cast_desire(npc, npc, NPC_HASTE_LVL_3, 99999999999000000)
    end

    super
  end
end
