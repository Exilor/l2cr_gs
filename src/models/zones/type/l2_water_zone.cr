class L2WaterZone < L2ZoneType
  def on_enter(char)
    char.inside_water_zone = true

    if char.player?
      pc = char.acting_player

      if pc.transformed? && !pc.transformation.can_swim?
        debug "Untransforming #{pc.name}."
        pc.stop_transformation(true)
      else
        pc.broadcast_user_info
      end
    elsif char.is_a?(L2Npc)
      char.known_list.known_players.each_value do |pc|
        if char.run_speed == 0
          pc.send_packet(ServerObjectInfo.new(char, pc))
        else
          pc.send_packet(NpcInfo.new(char, pc))
        end
      end
    end
  end

  def on_exit(char)
    char.inside_water_zone = false

    if char.player?
      char.acting_player.broadcast_user_info
    elsif char.is_a?(L2Npc)
      char.known_list.known_players.each_value do |pc|
        if char.run_speed == 0
          pc.send_packet(ServerObjectInfo.new(char, pc))
        else
          pc.send_packet(NpcInfo.new(char, pc))
        end
      end
    end
  end

  def water_z : Int32
    zone.high_z
  end
end
