class EffectHandler::SummonTrap < AbstractEffect
  @despawn_time : Int32
  @npc_id : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @despawn_time = params.get_i32("despawnTime", 0)
    @npc_id = params.get_i32("npcId", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    effected = info.effected
    return unless effected.player?
    return unless pc = effected.acting_player
    return if pc.looks_dead?
    return if pc.in_observer_mode?

    if @npc_id <= 0
      warn { "Invalid NPC ID: #{@npc_id} in skill ID: #{info.skill.id}." }
      return
    end



    return if pc.in_observer_mode? || pc.mounted?

    pc.trap.try &.unsummon

    unless templ = NpcData[@npc_id]?
      warn { "Invalid NPC ID: #{@npc_id} in skill ID: #{info.skill.id}." }
      return
    end

    trap = L2TrapInstance.new(templ, pc, @despawn_time)
    trap.heal!
    trap.invul = true
    trap.heading = pc.heading # what for? traps are symmetrical
    trap.spawn_me(*pc.xyz)
    pc.trap = trap
  end
end
