class Scripts::DrakosWarrior < AbstractNpcAI
  # NPCs
  private DRAKOS_WARRIOR = 22822
  private DRAKOS_ASSASSIN = 22823
  # Skill
  private SUMMON = SkillHolder.new(6858)

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_attack_id(DRAKOS_WARRIOR)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Rnd.rand(100) < 1
      add_skill_cast_desire(npc, npc, SUMMON, 99999999900000000)
      count = Rnd.rand(3) + 2
      count.times do
        add_spawn(DRAKOS_ASSASSIN, npc.x + rand(200), npc.y + rand(200), npc.z, 0, false, 0, false)
      end
    end

    super
  end
end
