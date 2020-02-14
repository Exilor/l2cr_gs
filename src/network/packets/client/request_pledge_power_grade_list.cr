class Packets::Incoming::RequestPledgePowerGradeList < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan
    privs = clan.all_rank_privs
    send_packet(PledgePowerGradeList.new(privs))
  end
end
