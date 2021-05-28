# Unifies BloodyKarik, BloodyBerserker and BloodyKarinness
class Scripts::BloodyFamily < AbstractNpcAI
  private FAMILY = {
    22854, # Bloody Karik
    22855, # Bloody Berserker
    22856  # Bloody Karinness
  }

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_kill_id(FAMILY)
    add_attack_id(FAMILY)
    add_teleport_id(FAMILY)
    add_move_finished_id(FAMILY)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "CORE_AI"
      if npc.is_a?(L2Attackable)
        npc.clear_aggro_list
        npc.core_ai_disabled = false
        start_quest_timer("RETURN_SPAWN", 300_000, npc, nil)
      end
    when "RETURN_SPAWN"
      if npc.is_a?(L2Attackable)
        npc.can_return_to_spawn_point = true
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.id.in?(FAMILY)
      dist_spawn = npc.calculate_distance(npc.spawn, false, false)
      if dist_spawn > 3000
        npc.core_ai_disabled = true
        npc.tele_to_location(npc.spawn)
      else
        if dist_spawn > 500 && npc.in_combat? && !npc.casting_now? && Rnd.rand(100) < 1
          FAMILY.each do |npc_id|
            SpawnTable.get_spawns(npc_id).each do |sp|
              obj = sp.last_spawn
              next unless obj && obj.alive? && (npc.z - obj.z).abs < 150
              range = obj.template.clan_help_range
              next unless npc.calculate_distance(obj, false, false).between?(range, 3000)
              next unless GeoData.can_see_target?(npc, obj)
              npc.core_ai_disabled = true
              npc.as(L2Attackable).can_return_to_spawn_point = false
              add_move_to_desire(npc, Location.new(obj.x + rand(-100..100), obj.y + rand(-100..100), obj.z + 20, 0), 0)
            end
          end
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.id.in?(FAMILY) && Rnd.rand(100) < 5
      new_z = npc.z + 20
      add_attack_desire(add_spawn(npc.id, npc.x, npc.y, new_z, npc.heading, false, 0), killer)
      add_attack_desire(add_spawn(npc.id, npc.x, npc.y - 10, new_z, npc.heading, false, 0), killer)
      add_attack_desire(add_spawn(npc.id, npc.x, npc.y - 20, new_z, npc.heading, false, 0), killer)
      add_attack_desire(add_spawn(npc.id, npc.x, npc.y + 10, new_z, npc.heading, false, 0), killer)
      add_attack_desire(add_spawn(npc.id, npc.x, npc.y + 20, new_z, npc.heading, false, 0), killer)
    end

    super
  end

  private def on_teleport(npc)
    start_quest_timer("CORE_AI", 100, npc, nil)
  end

  def on_move_finished(npc)
    start_quest_timer("CORE_AI", 100, npc, nil)
  end
end
