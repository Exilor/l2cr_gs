module UserCommandHandler::ClanPenalty
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    unless id == commands[0]
      return false
    end

    penalty = false
    format = "%Y-%m-%d"

    content = String.build(500) do |io|
      time = ::Time.ms

      if pc.clan_join_expiry_time > time
        io << "<td width=170>Unable to join a clan.</td><td width=100 align=center>"
        ::Time.from_ms(pc.clan_join_expiry_time).to_s(io, format)
        io << "</td>"
        penalty = true
      end

      if pc.clan_create_expiry_time > time
        io << "<td width=170>Unable to create a clan.</td><td width=100 align=center>"
        ::Time.from_ms(pc.clan_create_expiry_time).to_s(io, format)
        io << "</td>"
        penalty = true
      end

      clan = pc.clan
      if clan && clan.char_penalty_expiry_time > time
        io << "<td width=170>Unable to invite a clan member.</td><td width=100 align=center>"
        ::Time.from_ms(clan.char_penalty_expiry_time).to_s(io, format)
        io << "</td>"
        penalty = true
      end

      unless penalty
        io << "<td width=170>No penalty is imposed.</td><td width=100 align=center></td>"
      end

      io << "</tr></table><img src=\"L2UI.SquareWhite\" width=270 height=1></center></body></html>"
    end

    html = Packets::Outgoing::NpcHtmlMessage.new
    html.html = content
    pc.send_packet(html)

    true
  end

  def commands
    {100}
  end
end
