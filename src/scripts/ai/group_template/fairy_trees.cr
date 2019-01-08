class NpcAI::FairyTrees < AbstractNpcAI
  # NPC
  private SOUL_GUARDIAN = 27189 # Soul of Tree Guardian

  private MOBS = {
    27185, # Fairy Tree of Wind
    27186, # Fairy Tree of Star
    27187, # Fairy Tree of Twilight
    27188, # Fairy Tree of Abyss
  }

  # Skill
  private VENOMOUS_POISON = SkillHolder.new(4243, 1) # Venomous Poison

  # Misc
  private MIN_DISTANCE = 1500

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_kill_id(MOBS)
    add_spawn_id(MOBS)
  end

  def on_kill(npc, killer, is_summon)
    if npc.calculate_distance(killer, true, false) <= MIN_DISTANCE
      20.times do |i|
        guardian = add_spawn(SOUL_GUARDIAN, npc, false, 30000)
        attacker = is_summon ? killer.summon! : killer
        add_attack_desire(guardian, attacker)
        if Rnd.bool
          guardian.target = attacker
          guardian.do_cast(VENOMOUS_POISON.skill)
        end
      end
    end

    super
  end

  def on_spawn(npc)
    npc.no_rnd_walk = true
    npc.immobilized = true

    super
  end
end
