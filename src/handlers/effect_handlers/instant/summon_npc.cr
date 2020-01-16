class EffectHandler::SummonNpc < AbstractEffect
  @despawn_delay : Int32
  @npc_id : Int32
  @npc_count : Int32
  @random_offset : Int32
  @is_summon_spawn : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super

    @despawn_delay = params.get_i32("despawnDelay", 20_000)
    @npc_id = params.get_i32("npcId", 0)
    @npc_count = params.get_i32("npcCount", 1)
    @random_offset = params.get_i32("randomOffset", 0)
    @is_summon_spawn = params.get_bool("isSummonSpawn", false)
  end

  def effect_type : EffectType
    EffectType::SUMMON_NPC
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    return unless pc = info.effected?.as?(L2PcInstance)
    return if pc.looks_dead? || pc.mounted?

    if @npc_id <= 0 || @npc_count <= 0
      warn { "Invalid NPC ID or count for skill #{info.skill}." }
      return
    end

    unless template = NpcData[@npc_id]?
      warn { "Template for NPC ID #{@npc_id} not found." }
      return
    end

    case template.type
    when "L2Decoy"
      decoy = L2DecoyInstance.new(template, pc, @despawn_delay)
      decoy.heal!
      decoy.heading = pc.heading
      decoy.instance_id = pc.instance_id
      decoy.summoner = pc
      decoy.spawn_me(*pc.xyz)
      pc.decoy = decoy
    when "L2EffectPoint"
      ep = L2EffectPointInstance.new(template, pc)
      ep.heal!

      if info.skill.target_type.ground?
        if pos = pc.current_skill_world_position
          x, y, z = pos.xyz
        end
      end

      x ||= pc.x
      y ||= pc.y
      z ||= pc.z

      ep.invul = true
      ep.summoner = pc
      ep.spawn_me(x, y, z)
      @despawn_delay = NpcData[@npc_id].parameters.get_i32("despawn_time")
      if @despawn_delay > 0
        ep.schedule_despawn(@despawn_delay.to_i64 * 1000)
      end
    else
      sp = L2Spawn.new(@npc_id)
      x, y = pc.x, pc.y

      if @random_offset <= 20
        x += Rnd.bool ? Rnd.rand(20..50) : Rnd.rand(-50..-20)
        y += Rnd.bool ? Rnd.rand(20..50) : Rnd.rand(-50..-20)
      else
        x += Rnd.bool ? Rnd.rand(20..@random_offset) : Rnd.rand(-@random_offset..-20)
        y += Rnd.bool ? Rnd.rand(20..@random_offset) : Rnd.rand(-@random_offset..-20)
      end

      sp.x, sp.y, sp.z = x, y, pc.z
      sp.heading = pc.heading
      sp.stop_respawn

      npc = sp.do_spawn(@is_summon_spawn)
      npc.summoner = pc
      npc.name = template.name
      npc.title = template.name
      if @despawn_delay > 0
        npc.schedule_despawn(@despawn_delay.to_i64)
      end
      npc.running = false
    end
  end
end
