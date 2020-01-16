class Packets::Outgoing::ExShowScreenMessage < GameServerPacket
  TOP_LEFT = 0x01
  TOP_CENTER = 0x02
  TOP_RIGHT = 0x03
  MIDDLE_LEFT = 0x04
  MIDDLE_CENTER = 0x05
  MIDDLE_RIGHT = 0x06
  BOTTOM_CENTER = 0x07
  BOTTOM_RIGHT = 0x08

  @text : String?
  @parameters : Array(String)?

  def initialize(@text : String?, @time : Int32)
    @type = 2
    @sys_message_id = -1
    @unk1 = 0
    @unk2 = 0
    @unk3 = 0
    @fade = false
    @position = TOP_CENTER
    @size = 0
    @effect = false
    @npc_string = -1
  end

  def initialize(npc_string : NpcString, @position : Int32, @time : Int32, *params : String)
    @type = 2
    @sys_message_id = -1
    @unk1 = 0
    @unk2 = 0
    @unk3 = 0
    @fade = false
    @size = 0
    @effect = false
    @npc_string = npc_string.id
    add_string_parameter(*params)
  end

  def initialize(npc_string : NpcString, @position : Int32, @time : Int32)
    @type = 2
    @sys_message_id = -1
    @unk1 = 0
    @unk2 = 0
    @unk3 = 0
    @fade = false
    @size = 0
    @effect = false
    @npc_string = npc_string.id
  end

  def initialize(@type : Int32, @sys_message_id : Int32, @position : Int32, @unk1 : Int32, @size : Int32, @unk2 : Int32, @unk3 : Int32, @effect : Bool, @time : Int32, @fade : Bool, @text : String, npc_string : NpcString, params : String)
    @npc_string = npc_string.id
  end

  def add_string_parameter(*params : String)
    if parameters = @parameters
      parameters.concat(params)
    else
      @parameters = params.to_a
    end
  end

  private def write_impl
    c 0xfe
    h 0x39

    d @type
    d @sys_message_id
    d @position
    d @unk1
    d @size
    d @unk2
    d @unk3
    d @effect ? 1 : 0
    d @time
    d @fade ? 1 : 0
    d @npc_string
    if @npc_string == -1
      s @text
    else
      @parameters.try &.each { |param| s param }
    end
  end
end
