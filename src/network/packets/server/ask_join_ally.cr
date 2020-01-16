class Packets::Outgoing::AskJoinAlly < GameServerPacket
  initializer requestor_l2id : Int32, requestor_name : String

  private def write_impl
    c 0xbb

    d @requestor_l2id
    s @requestor_name
  end
end
