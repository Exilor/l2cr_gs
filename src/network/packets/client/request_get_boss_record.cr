class Packets::Incoming::RequestGetBossRecord < GameClientPacket
  no_action_request

  @boss_id = 0

  private def read_impl
    @boss_id = d
  end

  private def run_impl
    return unless pc = active_char

    if @boss_id != 0
      debug { "#{pc} @boss_id: #{@boss_id}" }
    end

    points = RaidBossPointsManager.get_points_by_owner_id(pc.l2id)
    ranking = RaidBossPointsManager.calculate_ranking(pc.l2id)
    list = RaidBossPointsManager.get_list(pc)

    pc.send_packet(ExGetBossRecord.new(ranking, points, list))
  end
end
