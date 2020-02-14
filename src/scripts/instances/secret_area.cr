class Scripts::SecretArea < Quest
  private class SAWorld < InstanceWorld
  end

  private TEMPLATE_ID = 118
  private GINBY = 32566
  private LELRIKIA = 32567
  private ENTER = 0
  private EXIT = 1
  private TELEPORTS = {
    Location.new(-23758, -8959, -5384),
    Location.new(-185057, 242821, 1576)
  }

  def initialize
    super(-1, self.class.simple_name, "gracia/instances")

    add_start_npc(GINBY)
    add_talk_id(GINBY)
    add_talk_id(LELRIKIA)
  end

  private def enter_instance(pc)
    if world = InstanceManager.get_player_world(pc)
      if world.is_a?(SAWorld)
        teleport_player(pc, TELEPORTS[ENTER], world.instance_id)
        return
      end

      pc.send_packet(SystemMessageId::YOU_HAVE_ENTERED_ANOTHER_INSTANT_ZONE_THEREFORE_YOU_CANNOT_ENTER_CORRESPONDING_DUNGEON)
      return
    end

    world = SAWorld.new
    world.instance_id = InstanceManager.create_dynamic_instance("SecretAreaInTheKeucereusFortress.xml")
    world.template_id = TEMPLATE_ID
    world.add_allowed(pc.l2id)
    world.status = 0
    InstanceManager.add_world(world)
    teleport_player(pc, TELEPORTS[ENTER], world.instance_id)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    if npc.id == GINBY && event.casecmp?("enter")
      enter_instance(pc)
      return "32566-01.html"
    elsif npc.id == LELRIKIA && event.casecmp?("exit")
      teleport_player(pc, TELEPORTS[EXIT], 0)
      return "32567-01.html"
    end

    get_no_quest_msg(pc)
  end
end
