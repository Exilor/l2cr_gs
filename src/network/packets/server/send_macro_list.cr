class Packets::Outgoing::SendMacroList < GameServerPacket
  initializer revision : Int32, count : Int32, mcr : Macro?

  private def write_impl
    c 0xe8

    d @revision
    c 0x00
    c @count
    c @mcr ? 1 : 0

    if mcr = @mcr
      d mcr.id
      s mcr.name
      s mcr.description
      s mcr.acronym
      c mcr.icon
      c mcr.commands.size

      mcr.commands.each_with_index do |command, i|
        c i + 1
        c command.type.to_i
        d command.d1
        c command.d2
        s command.cmd
      end
    end
  end
end
