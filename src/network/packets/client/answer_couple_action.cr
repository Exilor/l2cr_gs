class Packets::Incoming::AnswerCoupleAction < GameClientPacket
  @action_id = 0
  @answer = 0
  @char_id = 0

  def read_impl
    @action_id = d
    @answer = d
    @char_id = d
  end

  def run_impl
    return unless pc = active_char

    unless target = L2World.get_player(@char_id)
      warn "Player with ID #{@char_id} not found in L2World."
      return
    end

    if target.multi_social_target != pc.l2id || target.multi_social_action != @action_id
      return
    end

    case @answer
    when 0
      target.send_packet(SystemMessageId::COUPLE_ACTION_DENIED)
    when 1
      dst = pc.calculate_distance(target, false, false)
      if dst > 125 || dst < 15 || pc == target
        send_packet(SystemMessageId::TARGET_DO_NOT_MEET_LOC_REQUIREMENTS)
        target.send_packet(SystemMessageId::TARGET_DO_NOT_MEET_LOC_REQUIREMENTS)
        return
      end

      hd = Util.calculate_heading_from(pc, target)
      pc.broadcast_packet(ExRotation.new(pc.l2id, hd))
      pc.heading = hd

      hd = Util.calculate_heading_from(target, pc)
      target.heading = hd
      target.broadcast_packet(ExRotation.new(target.l2id, hd))
      pc.broadcast_packet(SocialAction.new(pc.l2id, @action_id))
      target.broadcast_packet(SocialAction.new(@char_id, @action_id))
    when -1
      sm = SystemMessage.c1_is_set_to_refuse_couple_actions
      sm.add_pc_name(pc)
      target.send_packet(sm)
    end

    target.set_multi_social_action(0, 0)
  end
end
