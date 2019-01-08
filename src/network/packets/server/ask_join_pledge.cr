class Packets::Outgoing::AskJoinPledge < GameServerPacket
  initializer requestor_id: Int32, subpledge_name: String?, pledge_type: Int32,
    pledge_name: String

  def write_impl
    c 0x2c

    d @requestor_id
    if @subpledge_name
      s @pledge_type > 0 ? @subpledge_name : @pledge_name
    end
    if @pledge_type != 0
      d @pledge_type
    end
    s @pledge_name
  end
end
