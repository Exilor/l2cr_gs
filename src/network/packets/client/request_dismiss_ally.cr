class Packets::Incoming::RequestDismissAlly < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    unless pc.clan_leader?
      pc.send_packet(SystemMessageId::FEATURE_ONLY_FOR_ALLIANCE_LEADER)
      return
    end

    pc.clan.dissolve_ally(pc)
  end
end
