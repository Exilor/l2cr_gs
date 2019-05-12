class Packets::Incoming::RequestExAddContactToContactList < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    unless Config.allow_mail
      return
    end

    # nil check on @name

    return unless pc = active_char

    pc.contact_list.remove(@name)
  end
end
