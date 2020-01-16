class Packets::Incoming::RequestShortcutRegister < GameClientPacket
  no_action_request

  @type = ShortcutType::NONE
  @slot = 0
  @page = 0
  @id = 0
  @level = 0
  @character_type = 0

  private def read_impl
    type_id = d.clamp(1, 6)
    @type = ShortcutType[type_id]
    slot = d
    @slot = slot % 12
    @page = slot // 12
    @id = d
    @level = d
    @character_type = d
  end

  private def run_impl
    return unless pc = active_char
    return unless @page.between?(0, 10)

    sc = Shortcut.new(@slot, @page, @type, @id, @level, @character_type)
    pc.register_shortcut(sc)
    send_packet(ShortcutRegister.new(sc))
  end
end
