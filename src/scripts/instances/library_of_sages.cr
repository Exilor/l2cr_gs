class Scripts::LibraryOfSages < AbstractInstance
  private class LoSWorld < InstanceWorld
    property! elcadia : L2Npc
  end

  # NPCs
  private SOPHIA1 = 32596
  private PILE_OF_BOOKS1 = 32809
  private PILE_OF_BOOKS2 = 32810
  private PILE_OF_BOOKS3 = 32811
  private PILE_OF_BOOKS4 = 32812
  private PILE_OF_BOOKS5 = 32813
  private SOPHIA2 = 32861
  private SOPHIA3 = 32863
  private ELCADIA_INSTANCE = 32785
  # Locations
  private START_LOC = Location.new(37063, -49813, -1128)
  private EXIT_LOC = Location.new(37063, -49813, -1128, 0, 0)
  private LIBRARY_LOC = Location.new(37355, -50065, -1127)
  # NpcString
  private ELCADIA_DIALOGS = {
    NpcString::I_MUST_ASK_LIBRARIAN_SOPHIA_ABOUT_THE_BOOK,
    NpcString::THIS_LIBRARY_ITS_HUGE_BUT_THERE_ARENT_MANY_USEFUL_BOOKS_RIGHT,
    NpcString::AN_UNDERGROUND_LIBRARY_I_HATE_DAMP_AND_SMELLY_PLACES,
    NpcString::THE_BOOK_THAT_WE_SEEK_IS_CERTAINLY_HERE_SEARCH_INCH_BY_INCH
  }
  # Misc
  private TEMPLATE_ID = 156

  def initialize
    super(self.class.simple_name)

    add_first_talk_id(
      SOPHIA2, ELCADIA_INSTANCE, PILE_OF_BOOKS1, PILE_OF_BOOKS2, PILE_OF_BOOKS3,
      PILE_OF_BOOKS4, PILE_OF_BOOKS5
    )
    add_start_npc(SOPHIA1, SOPHIA2, SOPHIA3)
    add_talk_id(SOPHIA1, SOPHIA2, SOPHIA3)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    world = InstanceManager.get_player_world(pc)
    if world.is_a?(LoSWorld)
      case event
      when "TELEPORT2"
        teleport_player(pc, LIBRARY_LOC, world.instance_id)
        world.elcadia.tele_to_location(*LIBRARY_LOC.xyz, 0, world.instance_id)
      when "exit"
        cancel_quest_timer("FOLLOW", npc, pc)
        pc.tele_to_location(EXIT_LOC)
        world.elcadia.delete_me
      when "FOLLOW"
        npc.running = true
        npc.ai.start_follow(pc)
        broadcast_npc_say(npc, Say2::NPC_ALL, ELCADIA_DIALOGS.sample)
        start_quest_timer("FOLLOW", 10000, npc, pc)
      when "ENTER"
        cancel_quest_timer("FOLLOW", npc, pc)
        teleport_player(pc, START_LOC, world.instance_id)
        world.elcadia.tele_to_location(*START_LOC.xyz, 0, world.instance_id)
      end
    end

    super
  end

  def on_talk(npc, talker)
    enter_instance(talker, LoSWorld.new, "LibraryOfSages.xml", TEMPLATE_ID)
    super
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world.add_allowed(pc.l2id)
    end

    teleport_player(pc, START_LOC, world.instance_id, false)
    spawn_elcadia(pc, world.as(LoSWorld))
  end

  private def spawn_elcadia(pc, world)
    world.elcadia?.try &.delete_me
    world.elcadia = add_spawn(ELCADIA_INSTANCE, pc, false, 0, false, pc.instance_id)
    start_quest_timer("FOLLOW", 3000, world.elcadia, pc)
  end
end
