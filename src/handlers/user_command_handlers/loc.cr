module UserCommandHandler::Loc
  extend self
  extend UserCommandHandler

  def use_user_command(id : Int32, pc : L2PcInstance) : Bool
    if zone = ZoneManager.get_zone(pc, L2RespawnZone)
      region = MapRegionManager.get_restart_region(pc, zone.all_respawn_points[Race::HUMAN]).loc_id
    else
      region = MapRegionManager.get_map_region_loc_id(pc)
    end

    if region > 0
      sm = Packets::Outgoing::SystemMessage[region]
      if sm.system_message_id.param_count == 3
        sm.add_int(pc.x)
        sm.add_int(pc.y)
        sm.add_int(pc.z)
      end
    else
      sm = Packets::Outgoing::SystemMessage.current_location_s1
      sm.add_string("#{pc.x}, #{pc.y}, #{pc.z}")
    end

    pc.send_packet(sm)

    true
  end

  def commands : Enumerable(Int32)
    {0}
  end
end
