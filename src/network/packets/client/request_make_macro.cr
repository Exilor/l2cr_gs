class Packets::Incoming::RequestMakeMacro < GameClientPacket
  MAX_MACRO_LENGTH = 12

  @id = 0
  @name = ""
  @desc = ""
  @acronym = ""
  @icon = 0
  @count = 0
  @macro : Macro?
  @commands_length = 0

  private def read_impl
    id = d
    name = s
    desc = s
    acro = s
    icon = c
    size = Math.min(c, MAX_MACRO_LENGTH)

    commands = [] of MacroCMD

    size.times do
      entry = c
      type  = c.clamp(1, 6)
      d1    = d
      d2    = c
      cmd   = s

      @commands_length += cmd.size
      macro_cmd = MacroCMD.new(entry, MacroType[type], d1, d2, cmd)
      commands << macro_cmd
    end

    @macro = Macro.new(id, icon, name, desc, acro, commands)
  end

  private def run_impl
    return unless pc = active_char
    return unless m = @macro

    if @commands_length > UInt8::MAX
      pc.send_packet(SystemMessageId::INVALID_MACRO)
      return
    end

    if pc.macros.size > 48
      pc.send_packet(SystemMessageId::YOU_MAY_CREATE_UP_TO_48_MACROS)
      return
    end

    if m.name.empty?
      pc.send_packet(SystemMessageId::ENTER_THE_MACRO_NAME)
      return
    end

    if m.description.size > 32
      pc.send_packet(SystemMessageId::MACRO_DESCRIPTION_MAX_32_CHARS)
      return
    end

    pc.register_macro(m)
  end
end
