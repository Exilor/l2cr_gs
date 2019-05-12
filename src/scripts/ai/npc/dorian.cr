class Scripts::Dorian < AbstractNpcAI
  # NPC
  private DORIAN = 25332
  # Items
  private SILVER_CROSS = 7153
  private BROKEN_SILVER_CROSS = 7154

  def initialize
    super(self.class.simple_name, "ai/npc")
    add_see_creature_id(DORIAN)
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.player?
      pc = creature.acting_player
      qs = pc.get_quest_state(Scripts::Q00024_InhabitantsOfTheForestOfTheDead.simple_name)
      if qs && qs.cond?(3)
        take_items(pc, SILVER_CROSS, -1)
        give_items(pc, BROKEN_SILVER_CROSS, 1)
        qs.set_cond(4, true)
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THAT_SIGN)
      end
    end

    super
  end
end
