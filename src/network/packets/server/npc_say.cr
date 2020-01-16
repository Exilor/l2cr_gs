class Packets::Outgoing::NpcSay < GameServerPacket
  @text : String?
  @npc_id : Int32

  def initialize(@l2id : Int32, @text_type : Int32, npc_id : Int32, @text : String)
    @npc_id = 1_000_000 + npc_id
    @npc_string = -1
  end

  def initialize(npc : L2Npc, @text_type : Int32, @text : String)
    @l2id = npc.l2id
    @npc_id = 1_000_000 + npc.id
    @npc_string = -1
  end

  def initialize(@l2id : Int32, @text_type : Int32, npc_id : Int32, npc_string : NpcString)
    @npc_id = 1_000_000 + npc_id
    @npc_string = npc_string.id
  end

  def initialize(npc : L2Npc, @text_type : Int32, npc_string : NpcString)
    @l2id = npc.l2id
    @npc_id = 1_000_000 + npc.id
    @npc_string = npc_string.id
  end

  def add_string_parameter(text : String)
    (@parameters ||= [] of String) << text
    self
  end

  def add_string_parameters(*params : String)
    add_string_parameters(params)
  end

  def add_string_parameters(params : Enumerable(String))
    params.each do |param|
      add_string_parameter(param)
    end
  end

  private def write_impl
    c 0x30

    d @l2id
    d @text_type
    d @npc_id
    d @npc_string
    if @npc_string == -1
      s @text
    elsif parameters = @parameters
      parameters.each { |param| s param }
    end
  end
end
