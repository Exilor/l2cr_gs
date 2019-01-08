struct L2Crest
  # include Identifiable

  enum CrestType : UInt8
    PLEDGE, PLEDGE_LARGE, ALLY

    def self.get_by_id(id : Int) : self?
      case id
      when 1 then PLEDGE
      when 2 then PLEDGE_LARGE
      when 3 then ALLY
      end
    end

    def id
      to_i + 1
    end
  end

  getter_initializer id: Int32, data: Bytes, type: CrestType

  def get_client_path(pc : L2PcInstance) : String
    case @type
    when .pledge?
      pc.send_packet(Packets::Outgoing::PledgeCrest.new(@id, @data))
      "Crest.crest_#{Config.server_id}_#{@id}"
    when .pledge_large?
      pc.send_packet(Packets::Outgoing::ExPledgeCrestLarge.new(@id, @data))
      "Crest.crest_#{Config.server_id}_#{@id}_l"
    else # .ally?
      pc.send_packet(Packets::Outgoing::AllyCrest.new(@id, @data))
      "Crest.crest_#{Config.server_id}_#{@id}"
    end
  end
end
