class Scripts::PolymorphingOnAttack < AbstractNpcAI
  private record PolyData, npc_id : Int32, hp_percent : Int32, chance : Int32,
    messages_index : Int32

  private MOBS = {
    21258 => PolyData.new(21259, 100, 100, -1), # Fallen Orc Shaman -> Sharp Talon Tiger (always polymorphs)
    21261 => PolyData.new(21262, 100,  20,  0), # Ol Mahum Transcender 1st stage
    21262 => PolyData.new(21263, 100,  10,  1), # Ol Mahum Transcender 2nd stage
    21263 => PolyData.new(21264, 100,   5,  2), # Ol Mahum Transcender 3rd stage
    21265 => PolyData.new(21271, 100,  33,  0), # Cave Ant Larva -> Cave Ant
    21266 => PolyData.new(21269, 100, 100, -1), # Cave Ant Larva -> Cave Ant (always polymorphs)
    21267 => PolyData.new(21270, 100, 100, -1), # Cave Ant Larva -> Cave Ant Soldier (always polymorphs)
    21271 => PolyData.new(21272,  66,  10,  1), # Cave Ant -> Cave Ant Soldier
    21272 => PolyData.new(21273,  33,   5,  2), # Cave Ant Soldier -> Cave Noble Ant
    21521 => PolyData.new(21522, 100,  30, -1), # Claws of Splendor
    21527 => PolyData.new(21528, 100,  30, -1), # Anger of Splendor
    21533 => PolyData.new(21534, 100,  30, -1), # Alliance of Splendor
    21537 => PolyData.new(21538, 100,  30, -1)  # Fang of Splendor
  }

  private TEXTS = {
    {
      NpcString::ENOUGH_FOOLING_AROUND_GET_READY_TO_DIE,
      NpcString::YOU_IDIOT_IVE_JUST_BEEN_TOYING_WITH_YOU,
      NpcString::NOW_THE_FUN_STARTS
    },
    {
      NpcString::I_MUST_ADMIT_NO_ONE_MAKES_MY_BLOOD_BOIL_QUITE_LIKE_YOU_DO,
      NpcString::NOW_THE_BATTLE_BEGINS,
      NpcString::WITNESS_MY_TRUE_POWER
    },
    {
      NpcString::PREPARE_TO_DIE,
      NpcString::ILL_DOUBLE_MY_STRENGTH,
      NpcString::YOU_HAVE_MORE_SKILL_THAN_I_THOUGHT
    }
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_attack_id(MOBS.keys)
  end

  def on_attack(npc, attacker, damage, is_summon)
    return unless npc.visible? && npc.alive?
    return unless tmp = MOBS[npc.id]?
    # return unless npc.current_hp <= (npc.max_hp * tmp.hp_percent) / 100
    return unless npc.hp_percent <= tmp.hp_percent
    return unless Rnd.rand(100) < tmp.chance

    if tmp.messages_index >= 0
      str = TEXTS[tmp.messages_index].sample
      cs = CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, str)
      npc.broadcast_packet(cs)
    end

    npc.delete_me
    new_npc = add_spawn(tmp.npc_id, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
    original_attacker = is_summon ? attacker.summon : attacker
    new_npc.set_running
    new_npc.as(L2Attackable).add_damage_hate(original_attacker, 0, 500)
    new_npc.set_intention(AI::ATTACK, original_attacker)

    super
  end
end
