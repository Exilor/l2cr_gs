module BaseBBSManager
  abstract def parse_cmd(command : String, pc : L2PcInstance)
  abstract def parse_write(a1 : String, a2 : String, a3 : String, a4 : String, a6 : String, pc : L2PcInstance)

  private def send_1001(html : String, pc : L2PcInstance)
    if html.size < 8192
      sb = Packets::Outgoing::ShowBoard.new(html, "1001")
      pc.send_packet(sb)
    end
  end

  private def send_1002(pc : L2PcInstance)
    send_1002(pc, " ", " ", "0")
  end

  private def send_1002(pc : L2PcInstance, string : String, string2 : String, string3 : String)
    args = {
      "0",
      "0",
      "0",
      "0",
      "0",
      "0",
      pc.name,
      pc.l2id,
      pc.account_name,
      "9",
      string2, # subject?
      string2, # subject?
      string, # text
      string3, # date?
      string3, # date?
      "0",
      "0"
    }

    sb = Packets::Outgoing::ShowBoard.new(args)
    pc.send_packet(sb)
  end
end
