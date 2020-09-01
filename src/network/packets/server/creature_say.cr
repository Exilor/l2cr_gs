class Packets::Outgoing::CreatureSay < GameServerPacket
  @l2id : Int32
  @text_type : Int32
  @char_id = 0
  @npc_string = -1
  @char_name : String?
  @text : String?

  private getter(params) { Array(String).new }

  initializer l2id : Int32, text_type : Int32, char_name : String, text : String

  def initialize(@l2id : Int32, @text_type : Int32, @char_id : Int32, npc_string : NpcString)
    @npc_string = npc_string.id
  end

  def initialize(@l2id : Int32, @text_type : Int32, @char_name : String, npc_string : NpcString)
    @npc_string = npc_string.id
  end

  def initialize(@l2id : Int32, @text_type : Int32, @char_id : Int32, sys_string : SystemMessageId)
    @npc_string = sys_string.id
  end

  def add_string(text : String)
    params << text
  end

  private def write_impl
    c 0x4a

    d @l2id
    d @text_type
    if char_name = @char_name
      s char_name
    else
      d @char_id
    end
    d @npc_string
    if text = @text
      s text
    else
      @params.try &.each { |param| s param }
    end
  end
end
