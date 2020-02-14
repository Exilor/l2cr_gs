class Scripts::JiniaGuildHideout1 < AbstractInstance
  private class JGH1World < InstanceWorld
  end

  # NPC
  private RAFFORTY = 32020
  # Location
  private START_LOC = Location.new(-23530, -8963, -5413)
  # Misc
  private TEMPLATE_ID = 140

  def initialize
    super(self.class.simple_name)

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY)
  end

  def on_talk(npc, talker)
    qs = talker.get_quest_state(Q10284_AcquisitionOfDivineSword.simple_name)
    if qs && qs.cond?(1)
      enter_instance(talker, JGH1World.new, "JiniaGuildHideout1.xml", TEMPLATE_ID)
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
