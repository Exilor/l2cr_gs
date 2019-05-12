class Packets::Incoming::AttackRequest < GameClientPacket
  @l2id = 0
  @origin_x = 0
  @origin_y = 0
  @origin_z = 0
  @attack_id = 0

  private def read_impl
    @l2id = d
    @origin_x = d
    @origin_y = d
    @origin_z = d
    @attack_id = c
  end

  private def run_impl
    return unless pc = active_char

    info = pc.effect_list.get_buff_info_by_abnormal_type(AbnormalType::BOT_PENALTY)
    if info
      info.effects.each do |effect|
        unless effect.check_condition(-1)
          pc.send_packet(SystemMessageId::YOU_HAVE_BEEN_REPORTED_SO_ACTIONS_NOT_ALLOWED)
          action_failed
          return
        end
      end
    end

    if pc.target_id == @l2id
      target = pc.target
    else
      target = L2World.find_object(@l2id)
    end

    unless target
      action_failed
      return
    end

    if (!target.targetable? && !pc.override_target_all?) ||
      (target.instance_id != pc.instance_id && pc.instance_id != -1) ||
      !target.visible_for?(pc)

      action_failed
      return
    end

    if pc.target != target
      target.on_action(pc)
    else
      if target.l2id != pc.l2id && pc.private_store_type.none?
        unless pc.active_requester
          target.on_forced_attack(pc)
          return
        end

        action_failed
      end
    end
  end
end
