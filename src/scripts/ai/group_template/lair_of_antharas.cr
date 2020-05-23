class Scripts::LairOfAntharas < AbstractNpcAI
  # NPC
  private DRAGON_KNIGHT = 22844
  private DRAGON_KNIGHT2 = 22845
  private ELITE_DRAGON_KNIGHT = 22846

  private DRAGON_GUARD = 22852
  private DRAGON_MAGE = 22853
  # Misc
  private KNIGHT_CHANCE = 30

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_kill_id(DRAGON_KNIGHT, DRAGON_KNIGHT2, DRAGON_GUARD, DRAGON_MAGE)
    add_spawn_id(DRAGON_KNIGHT, DRAGON_KNIGHT2, DRAGON_GUARD, DRAGON_MAGE)
    add_move_finished_id(DRAGON_GUARD, DRAGON_MAGE)
  end

  def on_adv_event(event, npc, pc)
    if event == "CHECK_HOME" && npc && npc.alive?
      if npc.calculate_distance(npc.spawn.location, false, false) > 10 && !npc.in_combat?
        npc.as(L2Attackable).return_home
      elsif npc.heading != npc.spawn.heading && !npc.in_combat?
        npc.heading = npc.spawn.heading
        npc.broadcast_packet(ValidateLocation.new(npc))
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when DRAGON_KNIGHT
      if Rnd.rand(100) > KNIGHT_CHANCE
        new_knight = add_spawn(DRAGON_KNIGHT2, npc, false, 0, true)
        npc.delete_me
        broadcast_npc_say(new_knight, Say2::NPC_SHOUT, NpcString::THOSE_WHO_SET_FOOT_IN_THIS_PLACE_SHALL_NOT_LEAVE_ALIVE)
        add_attack_desire(new_knight, killer)
      end
    when DRAGON_KNIGHT2
      if Rnd.rand(100) > KNIGHT_CHANCE
        elite_knight = add_spawn(ELITE_DRAGON_KNIGHT, npc, false, 0, true)
        npc.delete_me
        broadcast_npc_say(elite_knight, Say2::NPC_SHOUT, NpcString::IF_YOU_WISH_TO_SEE_HELL_I_WILL_GRANT_YOU_YOUR_WISH)
        add_attack_desire(elite_knight, killer)
      end
    when DRAGON_GUARD, DRAGON_MAGE
      cancel_quest_timer("CHECK_HOME", npc, nil)
    else
      # [automatically added else]
    end

    super
  end

  def on_spawn(npc)
    mob = npc.as(L2Attackable)
    mob.on_kill_delay = 0
    if npc.id == DRAGON_GUARD || npc.id == DRAGON_MAGE
      mob.no_random_walk = true
      start_quest_timer("CHECK_HOME", 10000, npc, nil, true)
    end

    super
  end
end
