class Packets::Incoming::RequestLinkHtml < GameClientPacket
  @link = ""

  private def read_impl
    @link = s
  end

  private def run_impl
    return unless pc = active_char

    debug @link

    if @link.empty?
      warn { "Player #{pc.name} sent an empty html link." }
      return
    end

    if @link.includes?("..")
      warn { "Player #{pc.name} sent an invalid html link: '#{@link}'." }
      return
    end

    html_l2id = pc.validate_html_action("link #{@link}")

    if html_l2id == -1
      warn { "Player #{pc.name} sent non cached html link: '#{@link}'." }
      return
    end

    if html_l2id > 0
      if !Util.inside_range_of_l2id?(pc, html_l2id, L2Npc::INTERACTION_DISTANCE)
        return
      end
    end

    msg = NpcHtmlMessage.new(html_l2id)
    msg.set_file(pc, "data/html/" + @link)
    send_packet(msg)
  end
end
