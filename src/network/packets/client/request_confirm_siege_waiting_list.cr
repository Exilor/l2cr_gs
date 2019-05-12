class Packets::Incoming::RequestConfirmSiegeWaitingList < GameClientPacket
  @approved = 0
  @castle_id = 0
  @clan_id = 0

  private def read_impl
    @approved = d
    @castle_id = d
    @clan_id = d
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan?
    return unless castle = CastleManager.get_castle_by_id(@castle_id)

    if castle.owner_id != pc.clan_id || !pc.clan_leader?
      return
    end

    siege = castle.siege

    unless siege.registration_over?
      if @approved == 1
        if siege.defender_waiting?(clan)
          siege.approve_siege_defender_clan(@clan_id)
        else
          return
        end
      else
        if siege.defender_waiting?(clan) || siege.defender?(clan)
          siege.remove_siege_clan(@clan_id)
        end
      end
    end

    pc.send_packet(SiegeDefenderList.new(castle))
  end
end
