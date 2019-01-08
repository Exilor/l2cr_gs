module UserCommandHandler::InstanceZone
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    return false unless id == commands[0]

    world = InstanceManager.get_player_world(pc)
    if world && world.template_id >= 0
      sm = Packets::Outgoing::SystemMessage.instant_zone_currently_inuse_s1
      sm.add_instance_name(world.template_id)
      pc.send_packet(sm)
    end

    first_message = true

    if instance_times = InstanceManager.get_all_instance_times(pc.l2id)
      instance_times.each do |instance_id, remaining_time|
        if remaining_time > 60
          if first_message
            first_message = false
            pc.send_packet(SystemMessageId::INSTANCE_ZONE_TIME_LIMIT)
          end

          hours = (remaining_time / 3600).to_i32
          minutes = (remaining_time % 3600).to_i32
          sm = Packets::Outgoing::SystemMessage.available_after_s1_s2_hours_s3_minutes
          sm.add_instance_name(instance_id)
          sm.add_int(hours)
          sm.add_int(minutes)
          pc.send_packet(sm)
        else
          InstanceManager.delete_instance_time(pc.l2id, instance_id)
        end
      end
    end

    if first_message
      pc.send_packet(SystemMessageId::NO_INSTANCEZONE_TIME_LIMIT)
    end

    true
  end

  def commands
    {114}
  end
end
