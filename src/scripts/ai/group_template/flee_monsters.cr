class Scripts::FleeMonsters < AbstractNpcAI
  private MOBS = {
    18150, # Victim
    18151, # Victim
    18152, # Victim
    18153, # Victim
    18154, # Victim
    18155, # Victim
    18156, # Victim
    18157, # Victim
    20002, # Rabbit
    20432, # Elpy
    22228, # Grey Elpy
    25604  # Mutated Elpy
  }

  private FLEE_DISTANCE = 500

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_attack_id(MOBS)
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    npc.disable_core_ai(true)
    npc.set_running

    summon = attacker.summon if is_summon
    attacker_loc = summon || attacker
    angle = Util.calculate_angle_from(attacker_loc, npc)
    radians = Math.to_radians(angle)
    x = (npc.x + (FLEE_DISTANCE * Math.cos(radians))).to_i
    y = (npc.y + (FLEE_DISTANCE * Math.sin(radians))).to_i
    z = npc.z

    dst = GeoData.move_check(*npc.xyz, x, y, z, attacker.instance_id)
    npc.set_intention(AI::MOVE_TO, dst)

    super
  end
end
