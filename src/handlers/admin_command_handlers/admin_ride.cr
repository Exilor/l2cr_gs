module AdminCommandHandler::AdminRide
  extend self
  extend AdminCommandHandler

  private PURPLE_MANED_HORSE_TRANSFORMATION_ID = 106
  private JET_BIKE_TRANSFORMATION_ID = 20001

  def use_admin_command(command, pc)
    unless player = get_ride_target(pc)
      return false
    end

    if command.starts_with?("admin_ride")
      if player.mounted? || player.has_summon?
        pc.send_message("Target already has a summon.")
        return false
      end

      pet_ride_id = 0

      if command.starts_with?("admin_ride_wyvern")
        pet_ride_id = 12621
      elsif command.starts_with?("admin_ride_strider")
        pet_ride_id = 12526
      elsif command.starts_with?("admin_ride_wolf")
        pet_ride_id = 16041
      elsif command.starts_with?("admin_ride_horse")
        if player.transformed? || player.in_stance?
          pc.send_packet(SystemMessageId::YOU_ALREADY_POLYMORPHED_AND_CANNOT_POLYMORPH_AGAIN)
        else
          TransformData.transform_player(PURPLE_MANED_HORSE_TRANSFORMATION_ID, player)
        end

        return true
      elsif command.starts_with?("admin_ride_bike")
        if player.transformed? || player.in_stance?
          pc.send_packet(SystemMessageId::YOU_ALREADY_POLYMORPHED_AND_CANNOT_POLYMORPH_AGAIN)
        else
          TransformData.transform_player(JET_BIKE_TRANSFORMATION_ID, player)
        end
      else
        pc.send_message("Command \"#{command}\" not recognized.")
        return false
      end

      player.mount(pet_ride_id, 0, false)

      return false
    elsif command.starts_with?("admin_unride")
      if player.transformation_id == PURPLE_MANED_HORSE_TRANSFORMATION_ID
        player.untransform
      end

      if player.transformation_id == JET_BIKE_TRANSFORMATION_ID
        player.untransform
      else
        player.dismount
      end
    end

    true
  end

  private def get_ride_target(pc)
    target = pc.target
    target.is_a?(L2PcInstance) && target != pc ? target : pc
  end

  def commands
    %w(
      admin_ride_horse
      admin_ride_bike
      admin_ride_wyvern
      admin_ride_strider
      admin_unride_wyvern
      admin_unride_strider
      admin_unride
      admin_ride_wolf
      admin_unride_wolf
    )
  end
end
