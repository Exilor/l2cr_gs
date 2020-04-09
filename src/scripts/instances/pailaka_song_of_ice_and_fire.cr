class Scripts::PailakaSongOfIceAndFire < AbstractInstance
  private class PailakaWorld < InstanceWorld
  end

  # NPCs
  private ADLER1 = 32497
  private GARGOS = 18607
  private BLOOM = 18616
  private BOTTLE = 32492
  private BRAZIER = 32493
  # Items
  private FIRE_ENHANCER = 13040
  private WATER_ENHANCER = 13041
  private SHIELD_POTION = 13032
  private HEAL_POTION = 13033
  # Location
  private TELEPORT = Location.new(-52875, 188232, -4696)
  # Misc
  private TEMPLATE_ID = 43
  private ZONE = 20108

  def initialize
    super(self.class.simple_name)

    add_start_npc(ADLER1)
    add_talk_id(ADLER1)
    add_attack_id(BOTTLE, BRAZIER)
    add_exit_zone_id(ZONE)
    add_see_creature_id(GARGOS)
    add_spawn_id(BLOOM)
    add_kill_id(BLOOM)
  end

  def on_enter_instance(pc : L2PcInstance, world : InstanceWorld, first_entrance : Bool)
    if first_entrance
      world.add_allowed(pc.l2id)
    end

    teleport_player(pc, TELEPORT, world.instance_id)
  end

  def on_adv_event(event, npc, pc)
    # debug "on_adv_event(event: #{event.inspect}, npc: #{npc}, pc: #{pc})."
    case event
    when "enter"
      pc = pc.not_nil!
      enter_instance(pc, PailakaWorld.new, "PailakaSongOfIceAndFire.xml", TEMPLATE_ID)
    when "GARGOS_LAUGH"
      npc = npc.not_nil!
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::OHHOHOH)
    when "TELEPORT"
      pc = pc.not_nil!
      teleport_player(pc, TELEPORT, pc.instance_id)
    when "DELETE"
      if npc
        npc.delete_me
      end
    when "BLOOM_TIMER"
      npc = npc.not_nil!
      start_quest_timer("BLOOM_TIMER2", Rnd.rand(2..4) * 60 * 1000, npc, nil)
    when "BLOOM_TIMER2"
      npc = npc.not_nil!
      npc.invisible = !npc.invisible?
      start_quest_timer("BLOOM_TIMER", 5000, npc, nil)
    else
      # [automatically added else]
    end


    super
  end

  def on_attack(npc, pc, damage, is_summon)
    if damage > 0 && npc.script_value?(0)
      case Rnd.rand(6)
      when 0
        if npc.id == BOTTLE
          npc.drop_item(pc, WATER_ENHANCER, Rnd.rand(1i64..6i64))
        end
      when 1
        if npc.id == BRAZIER
          npc.drop_item(pc, FIRE_ENHANCER, Rnd.rand(1i64..6i64))
        end
      when 2, 3
        npc.drop_item(pc, SHIELD_POTION, Rnd.rand(1i64..10i64))
      when 4, 5
        npc.drop_item(pc, HEAL_POTION, Rnd.rand(1i64..10i64))
      else
        # [automatically added else]
      end


      npc.script_value = 1
      start_quest_timer("DELETE", 3000, npc, nil)
    end

    super
  end

  def on_kill(npc, pc, is_summon)
    npc.drop_item(pc, Rnd.bool ? SHIELD_POTION : HEAL_POTION, Rnd.rand(1i64..7i64))
    super
  end

  def on_exit_zone(char, zone)
    if char.is_a?(L2PcInstance) && char.alive?
      if !char.teleporting? && char.online?
        world = InstanceManager.get_world(char.instance_id)
        if world && world.template_id == TEMPLATE_ID
          start_quest_timer("TELEPORT", 1000, nil, char)
        end
      end
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    if npc.script_value?(0) && creature.is_a?(L2PcInstance)
      npc.script_value = 1
      start_quest_timer("GARGOS_LAUGH", 1000, npc, creature)
    end

    super
  end

  def on_spawn(npc)
    npc.invisible = true
    start_quest_timer("BLOOM_TIMER", 1000, npc, nil)

    super
  end
end
