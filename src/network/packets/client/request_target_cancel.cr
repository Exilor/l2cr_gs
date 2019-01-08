class Packets::Incoming::RequestTargetCancel < GameClientPacket
  @unselect = 0

  def read_impl
    @unselect = h
  end

  def run_impl
    return unless pc = active_char

    if pc.locked_target?
      pc.send_packet(SystemMessageId::FAILED_DISABLE_TARGET)
      return
    end

    if @unselect == 0
      if pc.casting_now? && pc.can_abort_cast?
        pc.abort_cast
      elsif pc.target
        pc.target = nil
      # elsif pc.moving? # custom
      #   pc.stop_move # custom
      #   pc.abort_cast # custom
      #   pc.abort_attack # custom
      end
    elsif pc.target
      pc.target = nil
    elsif pc.in_airship?
      pc.broadcast_packet(TargetUnselected.new(pc))
    end
  end
end
