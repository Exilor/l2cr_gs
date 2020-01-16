class Scripts::SilentValley < AbstractNpcAI
  # Skills
  private BETRAYAL = SkillHolder.new(6033) # Treasure Seeker's Betrayal
  private BLAZE = SkillHolder.new(4157, 10) # NPC Blaze - Magic
  # Item
  private SACK = 13799 # Treasure Sack of the Ancient Giants
  # Chance
  private SPAWN_CHANCE = 2
  private CHEST_DIE_CHANCE = 5
  # Monsters
  private CHEST = 18693 # Treasure Chest of the Ancient Giants
  private GUARD1 = 18694 # Treasure Chest Guard
  private GUARD2 = 18695 # Treasure Chest Guard
  private MOBS = {
    20965, # Chimera Piece
    20966, # Changed Creation
    20967, # Past Creature
    20968, # Nonexistent Man
    20969, # Giant's Shadow
    20970, # Soldier of Ancient Times
    20971, # Warrior of Ancient Times
    20972, # Shaman of Ancient Times
    20973  # Forgotten Ancient People
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(MOBS)
    add_attack_id(CHEST, GUARD1, GUARD2)
    add_event_received_id(GUARD1, GUARD2)
    add_kill_id(MOBS)
    add_see_creature_id(MOBS)
    add_see_creature_id(GUARD1, GUARD2)
    add_spawn_id(CHEST, GUARD2)
  end

  def on_adv_event(event, npc, pc)
    if npc && npc.alive?
      case event
      when "CLEAR"
        npc.do_die(nil)
      when "CLEAR_EVENT"
        npc.broadcast_event("CLEAR_ALL_INSTANT", 2000, nil)
        npc.do_die(nil)
      when "SPAWN_CHEST"
        add_spawn(CHEST, npc.x - 100, npc.y, npc.z - 100, 0, false, 0)
      end
    end

    nil
  end

  def on_attack(npc, pc, damage, is_summon)
    case npc.id
    when CHEST
      if !is_summon && npc.script_value?(0)
        npc.script_value = 1
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::YOU_WILL_BE_CURSED_FOR_SEEKING_THE_TREASURE)
        npc.target = pc
        npc.do_cast(BETRAYAL)
      elsif is_summon || Rnd.rand(100) < CHEST_DIE_CHANCE
        npc.drop_item(pc, SACK, 1)
        npc.broadcast_event("CLEAR_ALL", 2000, nil)
        npc.do_die(nil)
        cancel_quest_timer("CLEAR_EVENT", npc, nil)
      end
    when GUARD1, GUARD2
      npc.target = pc
      npc.do_cast(BLAZE)
      add_attack_desire(npc, pc)
    else
      if is_summon
        add_attack_desire(npc, pc)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if Rnd.rand(1000) < SPAWN_CHANCE
      new_z = npc.z + 100
      add_spawn(GUARD2, npc.x + 100, npc.y, new_z, 0, false, 0)
      add_spawn(GUARD1, npc.x - 100, npc.y, new_z, 0, false, 0)
      add_spawn(GUARD1, npc.x, npc.y + 100, new_z, 0, false, 0)
      add_spawn(GUARD1, npc.x, npc.y - 100, new_z, 0, false, 0)
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.playable? && (pc = creature.acting_player)
      if npc.id == GUARD1 || npc.id == GUARD2
        npc.target = pc
        npc.do_cast(BLAZE)
        add_attack_desire(npc, pc)
      elsif creature.affected_by_skill?(BETRAYAL.skill_id)
        add_attack_desire(npc, pc)
      end
    end

    super
  end

  def on_spawn(npc)
    if npc.id == CHEST
      npc.invul = true
      start_quest_timer("CLEAR_EVENT", 300_000, npc, nil)
    else
      start_quest_timer("SPAWN_CHEST", 10000, npc, nil)
    end

    super
  end

  def on_event_received(event_name, sender, receiver, reference)
    if receiver && receiver.alive?
      case event_name
      when "CLEAR_ALL"
        start_quest_timer("CLEAR", 60_000, receiver, nil)
      when "CLEAR_ALL_INSTANT"
        receiver.do_die(nil)
      end
    end

    super
  end
end
