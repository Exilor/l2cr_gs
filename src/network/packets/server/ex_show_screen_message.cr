class Packets::Outgoing::ExShowScreenMessage < GameServerPacket
  TOP_LEFT = 0x01i8
  TOP_CENTER = 0x02i8
  TOP_RIGHT = 0x03i8
  MIDDLE_LEFT = 0x04i8
  MIDDLE_CENTER = 0x05i8
  MIDDLE_RIGHT = 0x06i8
  BOTTOM_CENTER = 0x07i8
  BOTTOM_RIGHT = 0x08i8
  NORMAL_SIZE = 0x00i8
  SMALL_SIZE = 0x01i8

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

  def initialize(npc_string : NpcString, position : Int32, time : Int32, param : String)
    initialize(npc_string, position, time, {param})
  end

  def initialize(npc_string : NpcString, @position : Int32, @time : Int32, params : Enumerable(String))
    @type = 2
    @sys_message_id = -1
    @unk1 = 0
    @unk2 = 0
    @unk3 = 0
    @fade = false
    @size = 0
    @effect = false
    @npc_string = npc_string.id
    add_string_parameter(params)
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

  def initialize(@type : Int32, @sys_message_id : Int32, @position : Int32, @unk1 : Int32, @size : Int32, @unk2 : Int32, @unk3 : Int32, @effect : Bool, @time : Int32, @fade : Bool, @text : String?, npc_string : NpcString, params : Enumerable(String)? = nil)
    @npc_string = npc_string.id
    add_string_parameter(params) if params
  end

  def add_string_parameter(param : String)
    add_string_parameter({param})
  end

  def add_string_parameter(params : Enumerable(String))
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
