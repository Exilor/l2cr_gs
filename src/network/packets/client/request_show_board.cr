class Packets::Incoming::RequestShowBoard < GameClientPacket
  no_action_request

  private def read_impl
    # @unknown = d
  end

  private def run_impl
    if pc = active_char
      CommunityBoardHandler.handle_parse_command(Config.bbs_default, pc)
    end
  end
end
