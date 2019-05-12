class Scripts::FrozenLabyrinth < AbstractNpcAI
  private PRONGHORN_SPIRIT = 22087
  private PRONGHORN = 22088
  private LOST_BUFFALO = 22093
  private FROST_BUFFALO = 22094

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_attack_id(PRONGHORN, FROST_BUFFALO)
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if npc.script_value?(0) && skill && !skill.magic?
      spawn_id = npc.id == PRONGHORN ? PRONGHORN_SPIRIT : LOST_BUFFALO

      diff = 0
      6.times do |i|
        x = diff  < 60 ? npc.x +      diff : npc.x
        y = diff >= 60 ? npc.y + diff - 40 : npc.y
        mob = add_spawn(spawn_id, x, y, npc.z, npc.heading, false, 0)
        add_attack_desire(mob, attacker)
        diff += 20
      end

      npc.script_value = 1
      npc.delete_me
    end

    super
  end
end
