class Scripts::SecretAreaInTheKeucereusFortress1 < AbstractInstance
  # NPC
  private GINBY = 32566
  # Location
  private START_LOC = Location.new(-23530, -8963, -5413)
  # Misc
  private TEMPLATE_ID = 117

  private class SAFK1World < InstanceWorld
  end

  def initialize
    super(self.class.simple_name)

    add_start_npc(GINBY)
    add_talk_id(GINBY)
  end

  def on_talk(npc, pc)
    if st = pc.get_quest_state(Q10270_BirthOfTheSeed.simple_name)
      if (5...20).covers?(st.memo_state)
        enter_instance(pc, SAFK1World.new, "SecretAreaInTheKeucereusFortress.xml", TEMPLATE_ID)
        if st.memo_state?(5)
          st.memo_state = 10
        end

        return "32566-01.html"
      end
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
