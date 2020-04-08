class L2WaterZone < L2ZoneType
  def on_enter(char)
    char.inside_water_zone = true

    case char
    when L2PcInstance
      if char.transformed? && (transformation = char.transformation) && !transformation.can_swim?
        char.stop_transformation(true)
      else
        char.broadcast_user_info
      end
    when L2Npc
      char.known_list.known_players.each_value do |pc|
        if char.run_speed == 0
          pc.send_packet(ServerObjectInfo.new(char, pc))
        else
          pc.send_packet(NpcInfo.new(char, pc))
        end
      end
    else
      # automatically added
    end

  end

  def on_exit(char)
    char.inside_water_zone = false

    case char
    when L2PcInstance
      char.broadcast_user_info
    when L2Npc
      char.known_list.known_players.each_value do |pc|
        if char.run_speed == 0
          pc.send_packet(ServerObjectInfo.new(char, pc))
        else
          pc.send_packet(NpcInfo.new(char, pc))
        end
      end
    else
      # automatically added
    end

  end

  def water_z : Int32
    zone.high_z
  end
end