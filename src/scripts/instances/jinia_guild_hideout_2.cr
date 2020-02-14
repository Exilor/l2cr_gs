class Scripts::JiniaGuildHideout2 < AbstractInstance
  private class JGH2World < InstanceWorld
  end

  # NPC
  private RAFFORTY = 32020
  # Location
  private START_LOC = Location.new(-23530, -8963, -5413, 0, 0)
  # Misc
  private TEMPLATE_ID = 141

  def initialize
    super(self.class.simple_name)

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY)
  end

  def on_talk(npc, talker)
    qs = talker.get_quest_state(Q10285_MeetingSirra.simple_name)
    if qs && qs.memo_state?(1)
      enter_instance(talker, JGH2World.new, "JiniaGuildHideout2.xml", TEMPLATE_ID)
      qs.set_cond(2, true)
    end

    super
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world.add_allowed(pc.l2id)
    end

    teleport_player(pc, START_LOC, world.instance_id, false)
  end
end
