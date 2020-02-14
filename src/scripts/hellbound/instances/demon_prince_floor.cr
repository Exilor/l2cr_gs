class Scripts::DemonPrinceFloor < AbstractInstance
  private class DPFWorld < InstanceWorld
  end

  # NPCs
  private GK_4 = 32748
  private CUBE = 32375
  private DEMON_PRINCE = 25540
  # Item
  private SEAL_BREAKER_5 = 15515
  # Locations
  private ENTRY_POINT = Location.new(-22208, 277056, -8239)
  private EXIT_POINT = Location.new(-19024, 277122, -8256)
  # Misc
  private TEMPLATE_ID = 142
  private MIN_LV = 78

  def initialize
    super(self.class.simple_name, "hellbound/Instances")

    add_start_npc(GK_4, CUBE)
    add_talk_id(GK_4, CUBE)
    add_kill_id(DEMON_PRINCE)
  end

  def on_talk(npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    if npc.id == GK_4
      unless pc.override_instance_conditions?
        party = pc.party
        if party.nil?
          html = "gk-noparty.htm"
        elsif !party.leader?(pc)
          html = "gk-noleader.htm"
        end
      end

      unless html
        enter_instance(pc, DPFWorld.new, "DemonPrince.xml", TEMPLATE_ID)
      end
    elsif npc.id == CUBE
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(DPFWorld)
        world.remove_allowed(pc.l2id)
        teleport_player(pc, EXIT_POINT, 0)
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    instance_id = npc.instance_id
    if instance_id > 0
      inst = InstanceManager.get_instance(instance_id).not_nil!
      world = InstanceManager.get_world(npc.instance_id).not_nil!
      inst.exit_loc = EXIT_POINT

      finish_instance(world)
      add_spawn(CUBE, -22144, 278744, -8239, 0, false, 0, false, instance_id)
    end

    super
  end

  private def check_conditions(pc)
    if pc.override_instance_conditions?
      return true
    end

    party = pc.party

    if party.nil? || !party.leader?(pc)
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end

    party.members.each do |m|
      if m.level < MIN_LV
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end

      unless Util.in_range?(500, pc, m, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end

      if InstanceManager.get_player_world(pc)
        sm = SystemMessage.you_have_entered_another_instant_zone_therefore_you_cannot_enter_corresponding_dungeon
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end

      reenter_time = InstanceManager.get_instance_time(m.l2id, TEMPLATE_ID)
      if Time.ms < reenter_time
        sm = SystemMessage.c1_may_not_re_enter_yet
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end

      if m.inventory.get_inventory_item_count(SEAL_BREAKER_5, -1, false) < 1
        sm = SystemMessage.c1_s_quest_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
    end

    true
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      party = pc.party
      if party.nil?
        teleport_player(pc, ENTRY_POINT, world.instance_id)
        pc.destroy_item_by_item_id("Quest", SEAL_BREAKER_5, 1, nil, true)
        world.add_allowed(pc.l2id)
      else
        party.members.each do |m|
          teleport_player(m, ENTRY_POINT, world.instance_id)
          m.destroy_item_by_item_id("Quest", SEAL_BREAKER_5, 1, nil, true)
          world.add_allowed(m.l2id)
        end
      end
    else
      teleport_player(pc, ENTRY_POINT, world.instance_id)
    end
  end
end
