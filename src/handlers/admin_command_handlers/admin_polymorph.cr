module AdminCommandHandler::AdminPolymorph
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_transform_menu"
      AdminHtml.show_admin_html(pc, "transform.htm")
      return true
    elsif command.starts_with?("admin_untransform")
      obj = pc.target
      if obj.is_a?(L2Character)
        obj.stop_transformation(true)
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    elsif command.starts_with?("admin_transform")
      unless player = pc.target.as?(L2PcInstance)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      if pc.sitting?
        pc.send_packet(SystemMessageId::CANNOT_TRANSFORM_WHILE_SITTING)
        return false
      end

      if player.transformed? || player.in_stance?
        unless command.includes?(" ")
          player.untransform
          return true
        end
        pc.send_packet(SystemMessageId::YOU_ALREADY_POLYMORPHED_AND_CANNOT_POLYMORPH_AGAIN)
        return false
      end

      if player.in_water?
        pc.send_packet(SystemMessageId::YOU_CANNOT_POLYMORPH_INTO_THE_DESIRED_FORM_IN_WATER)
        return false
      end

      if player.flying_mounted? || player.mounted?
        pc.send_packet(SystemMessageId::YOU_CANNOT_POLYMORPH_WHILE_RIDING_A_PET)
        return false
      end

      parts = command.split
      if parts.size != 2 || !parts[1].number?
        pc.send_message("Usage: #transform <id>")
        return false
      end

      id = parts[1].to_i
      unless TransformData.transform_player(id, player)
        player.send_message("Unknown transformation id: #{id}")
        return false
      end
    end

    if command.starts_with?("admin_polymorph")
      parts = command.split
      if parts.size < 2 || !parts[1].number?
        pc.send_message("Usage: #polymorph [type] <id>")
        return false
      end

      if parts.size > 2
        do_polymorph(pc, pc.target, parts[2], parts[1])
      else
        do_polymorph(pc, pc.target, parts[1], "npc")
      end
    elsif command == "admin_unpolymorph"
      do_unpolymorph(pc, pc.target)
    end

    true
  end

  private def do_polymorph(pc, obj, id, type)
    if obj
      obj.poly.set_poly_info(type, id)
      # animation
      if obj.is_a?(L2Character)
        msu = MagicSkillUse.new(obj, 1008, 1, 4000, 0)
        obj.broadcast_packet(msu)
        sg = SetupGauge.blue(4000)
        obj.send_packet(sg)
      end
      # end of animation
      obj.decay_me
      obj.spawn_me(*obj.xyz)
      pc.send_message("Polymorph succeed")
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
    end
  end

  private def do_unpolymorph(pc, target)
    if target
      target.poly.set_poly_info(nil, "1")
      target.decay_me
      target.spawn_me(*target.xyz)
      pc.send_message("Unpolymorph succeed")
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
    end
  end

  def commands
    {
      "admin_polymorph",
      "admin_unpolymorph",
      "admin_transform",
      "admin_untransform",
      "admin_transform_menu"
    }
  end
end
