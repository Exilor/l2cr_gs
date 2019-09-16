abstract class Packets::Outgoing::AbstractMessagePacket < GameServerPacket
  private record SMParam, type : Int8,
    value : String | Int32 | Int64 | {Int32, Int32} | {Int32, Int32, Int32}

  private TEXT          =  0i8
  private INT_NUMBER    =  1i8
  private NPC_NAME      =  2i8
  private ITEM_NAME     =  3i8
  private SKILL_NAME    =  4i8
  private CASTLE_NAME   =  5i8
  private LONG_NUMBER   =  6i8
  private ZONE_NAME     =  7i8
  private ELEMENT_NAME  =  9i8
  private INSTANCE_NAME = 10i8
  private DOOR_NAME     = 11i8
  private PLAYER_NAME   = 12i8
  private SYSTEM_STRING = 13i8

  getter system_message_id

  def initialize(@system_message_id : SystemMessageId)
    if param_count > 0
      ptr = Pointer(SMParam).malloc(param_count)
    else
      ptr = Pointer(SMParam).null
    end

    @params = Pointer::Appender(SMParam).new(ptr)
  end

  delegate id, to: @system_message_id

  private def param_count
    @system_message_id.param_count
  end

  private def add_param(param)
    if @params.size == param_count
      raise "#{@system_message_id} takes #{param_count} parameters"
    end

    @params << param

    self
  end

  def add_string(str : String) : self
    add_param(SMParam.new(TEXT, str))
  end

  def add_castle_id(id : Int32) : self
    add_param(SMParam.new(CASTLE_NAME, id))
  end

  def add_int(int : Number) : self
    add_param(SMParam.new(INT_NUMBER, int.to_i32))
  end

  def add_long(long : Number) : self
    add_param(SMParam.new(LONG_NUMBER, long.to_i64))
  end

  def add_char_name(char : L2Character) : self
    case char
    when L2Npc, L2Summon
      if char.template.using_server_side_name?
        return add_string(char.template.name)
      end

      add_npc_name(char)
    when L2PcInstance
      add_pc_name(char)
    when L2DoorInstance
      add_door_name(char.id)
    else
      add_string(char.name)
    end
  end

  def add_pc_name(pc : L2PcInstance) : self
    add_param(SMParam.new(PLAYER_NAME, pc.appearance.visible_name))
  end

  def add_npc_name(npc : L2Npc) : self
    add_npc_name(npc.template)
  end

  def add_npc_name(npc : L2Summon) : self
    add_npc_name(npc.id)
  end

  def add_npc_name(template : L2NpcTemplate) : self
    if template.using_server_side_name?
      return add_string(template.name)
    end

    add_npc_name(template.id)
  end

  def add_npc_name(id : Int32) : self
    add_param(SMParam.new(NPC_NAME, id + 1_000_000))
  end

  def add_item_name(item : L2Item | L2ItemInstance) : self
    add_item_name(item.id)
  end

  def add_item_name(id : Int32) : self
    item = ItemTable[id]
    if item.display_id != id
      return add_string(item.name)
    end

    add_param(SMParam.new(ITEM_NAME, id))
  end

  def add_zone_name(x : Int32, y : Int32, z : Int32) : self
    add_param(SMParam.new(ZONE_NAME, {x, y, z}))
  end

  def add_skill_name(skill : Skill) : self
    if skill.id != skill.display_id
      return add_string(skill.name)
    end

    add_skill_name(skill.id, skill.level)
  end

  def add_skill_name(id : Int32, lvl : Int32 = 1) : self
    add_param(SMParam.new(SKILL_NAME, {id, lvl}))
  end

  def add_elemental(type : Int) : self
    add_param(SMParam.new(ELEMENT_NAME, type.to_i32))
  end

  def add_system_string(type : Int32) : self
    add_param(SMParam.new(SYSTEM_STRING, type))
  end

  def add_instance_name(type : Int32) : self
    add_param(SMParam.new(INSTANCE_NAME, type))
  end

  def add_door_name(id : Int32)
    add_param(SMParam.new(DOOR_NAME, id))
  end

  def write_impl
    d id

    if param_count == 0
      d 0
      return
    end

    if @params.size < param_count
      raise "Too few parameters for #{@system_message_id} " \
        "(given #{@params.size} but #{param_count} required)"
    end

    d param_count
    param_count.times do |i|
      param = @params.@start[i]
      d param.type
      case param.type
      when TEXT, PLAYER_NAME
        s param.value.as(String)
      when LONG_NUMBER
        q param.value.as(Int64)
      when SKILL_NAME
        skill_id, lvl = param.value.as({Int32, Int32})
        d skill_id
        d lvl
      when ZONE_NAME
        x, y, z = param.value.as({Int32, Int32, Int32})
        d x
        d y
        d z
      else
      # ITEM_NAME, CASTLE_NAME, INT_NUMBER, NPC_NAME, ELEMENT_NAME,
      # SYSTEM_STRING, INSTANCE_NAME, DOOR_NAME
        d param.value.as(Int32)
      end
    end
  end

  def to_s(io : IO)
    io << self.class.simple_name << '(' << @system_message_id << ')'
  end
end
