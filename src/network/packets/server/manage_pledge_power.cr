class Packets::Outgoing::ManagePledgePower < GameServerPacket
  initializer clan : L2Clan, action : Int32, rank : Int32

  private def write_impl
    if @action == 1
      c 0x2a

      q 0
      d @clan.get_rank_privs(@rank).mask
    end
  end
end
