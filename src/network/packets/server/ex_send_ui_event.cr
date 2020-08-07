class Packets::Outgoing::ExSendUIEvent < GameServerPacket
  @l2id : Int32
  @params = Slice(String).empty

  def initialize(pc : L2PcInstance, type : Bool, count_up : Bool, start_time : Int32, end_time : Int32, param : String)
    initialize(pc, type, count_up, start_time, end_time, -1, {param})
  end

  def initialize(pc : L2PcInstance, type : Bool, count_up : Bool, start_time : Int32, end_time : Int32, npc_string : NpcString, *params : String)
    initialize(pc, type, count_up, start_time, end_time, npc_string.id, params)
  end

  def initialize(pc : L2PcInstance, type : Bool, count_up : Bool, start_time : Int32, end_time : Int32, npc_string : NpcString, params : Enumerable(String)? = nil)
    initialize(pc, type, count_up, start_time, end_time, npc_string.id, params)
  end

  def initialize(pc : L2PcInstance, type : Bool, count_up : Bool, start_time : Int32, end_time : Int32, npc_string_id : Int32, params : Enumerable(String)? = nil)
    @type = type
    @count_up = count_up
    @start_time = start_time
    @end_time = end_time
    @npc_string_id = npc_string_id
    if params
      @params = params.to_slice
    end
    @l2id = pc.l2id
  end

  private def write_impl
    c 0xfe
    h 0x8e

    d @l2id
    d @type ? 1 : 0
    d 0
    d 0
    s @count_up ? "1" : "0"
    s (@start_time // 60).to_s
    s (@start_time % 60).to_s
    s (@end_time // 60).to_s
    s (@end_time % 60).to_s
    d @npc_string_id
    @params.each { |param| s param }
  end
end
