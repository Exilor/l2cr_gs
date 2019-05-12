class Packets::Incoming::BypassUserCmd < GameClientPacket
  @cmd = 0

  private def read_impl
    @cmd = d
  end

  private def run_impl
    return unless pc = active_char

    unless handler = UserCommandHandler[@cmd]
      if pc.gm?
        pc.send_message("User CMD #{@cmd.inspect} does not exist.")
      end

      return
    end

    handler.use_user_command(@cmd, pc)
  end
end
