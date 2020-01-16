class Packets::Incoming::Action < GameClientPacket
  no_action_request

  @l2id = 0
  @x = 0
  @y = 0
  @z = 0
  @action_id = 0

  private def read_impl
    @l2id = d
    @x = d
    @y = d
    @z = d
    @action_id = c
  end

  private def run_impl
    return unless pc = active_char

    if pc.in_observer_mode?
      pc.send_packet(SystemMessageId::OBSERVERS_CANNOT_PARTICIPATE)
      action_failed
      return
    end

    if info = pc.effect_list.get_buff_info_by_abnormal_type(AbnormalType::BOT_PENALTY)
      info.effects.each do |effect|
        unless effect.check_condition(-4)
          pc.send_packet(SystemMessageId::YOU_HAVE_BEEN_REPORTED_SO_ACTIONS_NOT_ALLOWED)
          action_failed
          return
        end
      end
    end

    if pc.target_id == @l2id
      obj = pc.target
    elsif (airship = pc.airship) && airship.helm_l2id == @l2id
      obj = airship
    else
      obj = L2World.find_object(@l2id)
    end

    unless obj
      warn "L2Object with ID #{@l2id} not found in L2World."
      summon = pc.summon
      if summon && summon.l2id == @l2id
        warn "It's #{pc.name} summon."
        if summon.world_region.nil?
          warn "Its region is nil."
        end
      end

      L2World.world_regions.each &.each do |reg|
        reg.objects.each do |l2id, o|
          if o.l2id == @l2id
            warn "Found object (#{o}) missing from L2World in region #{reg}."
            L2World.store_object(o)
            obj = o
            break
          end
        end
      end

      unless obj
        action_failed
        return
      end
    end

    if obj.playable? && obj.acting_player.not_nil!.duel_state.dead?
      pc.send_packet(SystemMessageId::OTHER_PARTY_IS_FROZEN)
      action_failed
      return
    elsif !obj.targetable? && !pc.override_target_all?
      action_failed
      return
    elsif obj.instance_id != pc.instance_id && pc.instance_id != -1
      warn { "#{pc} and #{obj} are not in the same instance_id (pc: #{pc.instance_id}, obj: #{obj.instance_id})." }
      action_failed
      return
    end

    unless obj.visible_for?(pc)
      warn { "#{obj} is not visible for #{pc}." }
      action_failed
      return
    end

    if pc.active_requester
      debug { "#{pc} has an active requester (#{pc.active_requester})." }
      action_failed
      return
    end

    case @action_id
    when 0 # Normal click
      obj.on_action(pc)
    when 1 # Shift click
      obj.on_action_shift(pc)
    else
      warn { "#{pc} requested invalid action #{@action_id}." }
      action_failed
    end
  end
end
