class Scripts::ElcadiasTent < AbstractInstance
  private class ETWorld < InstanceWorld
  end

  # NPCs
  private ELCADIA = 32784
  private GRUFF_LOOKING_MAN = 32862
  # Locations
  private START_LOC = Location.new(89797, -238081, -9632)
  private EXIT_LOC = Location.new(43347, -87923, -2820)
  # Misc
  private TEMPLATE_ID = 158

  def initialize
    super(self.class.simple_name)

    add_first_talk_id(GRUFF_LOOKING_MAN, ELCADIA)
    add_start_npc(GRUFF_LOOKING_MAN, ELCADIA)
    add_talk_id(GRUFF_LOOKING_MAN, ELCADIA)
  end

  def on_talk(npc, pc)
    if npc.id == GRUFF_LOOKING_MAN
      q10292 = pc.get_quest_state(Q10292_SevenSignsGirlOfDoubt.simple_name)
      q10293 = pc.get_quest_state(Q10293_SevenSignsForbiddenBookOfTheElmoreAdenKingdom.simple_name)
      q10294 = pc.get_quest_state(Q10294_SevenSignsToTheMonasteryOfSilence.simple_name)
      q10296 = pc.get_quest_state(Q10296_SevenSignsOneWhoSeeksThePowerOfTheSeal.simple_name)
      if (q10292 && q10292.memo_state > 1 && q10292.memo_state < 9) ||
         (q10292 && q10292.completed? && q10293.nil?) ||
         (q10293 && q10293.started?) ||
         (q10293 && q10293.completed? && q10294.nil?) ||
         (q10296 && q10296.memo_state > 2 && q10296.memo_state < 4)

        enter_instance(pc, ETWorld.new, "ElcadiasTent.xml", TEMPLATE_ID)
      else
        return "32862-01.html"
      end
    else
      world = InstanceManager.get_player_world(pc).not_nil!
      world.remove_allowed(pc.l2id)
      pc.instance_id = 0
      pc.tele_to_location(EXIT_LOC)
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
