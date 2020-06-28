class Scripts::NornilsGardenQuest < AbstractInstance
  private class NGQWorld < InstanceWorld
    property origin_loc : Location?
  end

  # NPCs
  private RODENPICULA = 32237
  private MOTHER_NORNIL = 32239
  # Location
  private ENTER_LOC = Location.new(-119538, 87177, -12592)
  # Misc
  private TEMPLATE_ID = 12

  def initialize
    super("NornilsGardenQuest")

    add_start_npc(RODENPICULA, MOTHER_NORNIL)
    add_talk_id(RODENPICULA, MOTHER_NORNIL)
    add_first_talk_id(RODENPICULA, MOTHER_NORNIL)
  end

  def check_conditions(pc)
    qs = pc.get_quest_state(Scripts::Q00236_SeedsOfChaos.simple_name)
    !!qs && qs.memo_state.between?(40, 45)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!
    q236 = player.get_quest_state(Scripts::Q00236_SeedsOfChaos.simple_name).not_nil!
    case event
    when "enter"
      if check_conditions(player)
        world = NGQWorld.new
        world.origin_loc = player.location
        enter_instance(player, world, "NornilsGardenQuest.xml", TEMPLATE_ID)
        q236.set_cond(16, true)
        htmltext = "32190-02.html"
      else
        htmltext = "32190-03.html"
      end
    when "exit"
      if q236 && q236.completed?
        world = InstanceManager.get_player_world(player).as(NGQWorld)
        world.remove_allowed(player.l2id)
        finish_instance(world, 5000)

        player.instance_id = 0
        player.tele_to_location(world.origin_loc.not_nil!)
        htmltext = "32239-03.html"
      end
    end


    htmltext
  end

  def on_enter_instance(player, world, first_entrance)
    if first_entrance
      world.add_allowed(player.l2id)
    end

    teleport_player(player, ENTER_LOC, world.instance_id, false)
  end

  def on_first_talk(npc, player)
    q236 = player.get_quest_state(Scripts::Q00236_SeedsOfChaos.simple_name)
    case npc.id
    when RODENPICULA
      q236 && q236.completed? ? "32237-02.html" : "32237-01.html"
    when MOTHER_NORNIL
      q236 && q236.completed? ? "32239-02.html" : "32239-01.html"
    end

  end
end
