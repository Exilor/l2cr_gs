class Packets::Incoming::RequestShortcutDelete < GameClientPacket
  no_action_request

  @slot = 0
  @page = 0

  private def read_impl
    id = d
    @slot = id % 12
    @page = id / 12
  end

  private def run_impl
    return unless pc = active_char
    if 0 <= @page <= 10
      pc.delete_shortcut(@slot, @page)
    end
  end
end
