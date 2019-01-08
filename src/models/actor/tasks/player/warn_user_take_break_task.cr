struct WarnUserTakeBreakTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    if @pc.online?
      @pc.send_packet(SystemMessageId::PLAYING_FOR_LONG_TIME)
    else
      @pc.stop_warn_user_take_break
    end
  end
end
