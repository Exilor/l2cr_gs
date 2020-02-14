class Packets::Incoming::RequestPledgePower < GameClientPacket
  @rank = 0
  @action = 0
  @privs = 0

  private def read_impl
    @rank = d
    @action = d
    if @action == 2
      @privs = d
    else
      @privs = 0
    end
  end

  private def run_impl
    return unless (pc = active_char) && (clan = pc.clan)

    if @action == 2
      if pc.clan_leader?
        if @rank == 9
          @privs &= ClanPrivilege::CL_VIEW_WAREHOUSE.mask |
            ClanPrivilege::CH_OPEN_DOOR.mask |
            ClanPrivilege::CS_OPEN_DOOR.mask
        end

        clan.set_rank_privs(@rank, @privs)
      end
    else
      pc.send_packet(ManagePledgePower.new(clan, @action, @rank))
    end
  end
end
