class Scripts::WarriorFishingBlock < AbstractNpcAI
  private MONSTERS = {
    18319, # Caught Frog
    18320, # Caught Undine
    18321, # Caught Rakul
    18322, # Caught Sea Giant
    18323, # Caught Sea Horse Soldier
    18324, # Caught Homunculus
    18325, # Caught Flava
    18326  # Caught Gigantic Eye
  }

  private CHANCE_TO_SHOUT_ON_ATTACK = 33
  private DESPAWN_TIME = 50 * 1000 # 50 seconds to despawn

  private NPC_STRINGS_ON_SPAWN = {
    NpcString::CROAK_CROAK_FOOD_LIKE_S1_IN_THIS_PLACE,
    NpcString::S1_HOW_LUCKY_I_AM,
    NpcString::PRAY_THAT_YOU_CAUGHT_A_WRONG_FISH_S1
  }
  private NPC_STRINGS_ON_ATTACK = {
    NpcString::DO_YOU_KNOW_WHAT_A_FROG_TASTES_LIKE,
    NpcString::I_WILL_SHOW_YOU_THE_POWER_OF_A_FROG,
    NpcString::I_WILL_SWALLOW_AT_A_MOUTHFUL
  }
  private NPC_STRINGS_ON_KILL = {
    NpcString::UGH_NO_CHANCE_HOW_COULD_THIS_ELDER_PASS_AWAY_LIKE_THIS,
    NpcString::CROAK_CROAK_A_FROG_IS_DYING,
    NpcString::A_FROG_TASTES_BAD_YUCK
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(MONSTERS)
    add_kill_id(MONSTERS)
    add_spawn_id(MONSTERS)
  end

  def on_adv_event(event, npc, pc)
    unless npc.is_a?(L2Attackable)
      raise "#{npc} should be a L2Attackable"
    end

    case event
    when "SPAWN"
      target = npc.target.as?(L2PcInstance)
      if target.nil?
        npc.decay_me
      else
        broadcast_npc_say(npc, Say2::NPC_ALL, NPC_STRINGS_ON_SPAWN.sample, target.name)
        npc.add_damage_hate(target, 0, 2000)
        npc.notify_event(AI::ATTACKED, target)
        npc.add_attacker_to_attack_by_list(target)
        start_quest_timer("DESPAWN", DESPAWN_TIME, npc, target)
      end
    when "DESPAWN"
      npc.decay_me
    else
      # [automatically added else]
    end


    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Rnd.rand(100) < CHANCE_TO_SHOUT_ON_ATTACK
      broadcast_npc_say(npc, Say2::NPC_ALL, NPC_STRINGS_ON_ATTACK.sample)
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    broadcast_npc_say(npc, Say2::NPC_ALL, NPC_STRINGS_ON_KILL.sample)
    cancel_quest_timer("DESPAWN", npc, killer)

    super
  end

  def on_spawn(npc)
    start_quest_timer("SPAWN", 2000, npc, nil)
    super
  end
end
