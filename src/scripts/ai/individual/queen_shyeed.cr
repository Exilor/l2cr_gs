class Scripts::QueenShyeed < AbstractNpcAI
  # NPC
  private SHYEED = 25671
  private SHYEED_LOC = Location.new(79634, -55428, -6104, 0)

  # Respawn
  private RESPAWN = 86_400_000 # 24 h
  private RANDOM_RESPAWN = 43200000 # 12 h

  @mob_buff_zone : L2EffectZone
  @mob_buff_display_zone : L2EffectZone
  @pc_buff_zone : L2EffectZone

  def initialize
    super(self.class.simple_name, "ai/individual")

    @mob_buff_zone = ZoneManager.get_zone_by_id(200103, L2EffectZone).not_nil!
    @mob_buff_display_zone = ZoneManager.get_zone_by_id(200104, L2EffectZone).not_nil!
    @pc_buff_zone = ZoneManager.get_zone_by_id(200105, L2EffectZone).not_nil!

    add_kill_id(SHYEED)
    spawn_shyeed
  end

  def on_adv_event(event, npc, pc)
    case event
    when "respawn"
      spawn_shyeed
    when "despawn"
      npc = npc.not_nil!
      if npc.alive?
        npc.delete_me
        start_respawn
      end
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::SHYEEDS_CRY_IS_STEADILY_DYING_DOWN)
    start_respawn
    @pc_buff_zone.enabled = true

    super
  end

  private def spawn_shyeed
    respawn = load_global_quest_var("Respawn")
    remain = respawn.empty? ? 0 : respawn.to_i64 &- Time.ms
    if remain > 0
      start_quest_timer("respawn", remain, nil, nil)
      return
    end
    npc = add_spawn(SHYEED, SHYEED_LOC, false, 0)
    start_quest_timer("despawn", 10_800_000, npc, nil)
    @pc_buff_zone.enabled = false
    @mob_buff_zone.enabled = true
    @mob_buff_display_zone.enabled = true
  end

  private def start_respawn
    respawn_time = RESPAWN - Rnd.rand(RANDOM_RESPAWN)
    save_global_quest_var("Respawn", (Time.ms &+ respawn_time).to_s)
    start_quest_timer("respawn", respawn_time, nil, nil)
    @mob_buff_zone.enabled = false
    @mob_buff_display_zone.enabled = false
  end
end
