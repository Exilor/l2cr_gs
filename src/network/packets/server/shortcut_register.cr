class Packets::Outgoing::ShortcutRegister < GameServerPacket
  initializer shortcut : Shortcut

  def write_impl
    c 0x44

    d @shortcut.type.to_i
    d @shortcut.slot + (@shortcut.page * 12)

    case @shortcut.type
    when .item? # ShortcutType::ITEM
      d @shortcut.id
      d @shortcut.character_type
      d @shortcut.shared_reuse_group
      d 0x00
      d 0x00
      d 0x00
    when .skill? # ShortcutType::SKILL
      d @shortcut.id
      d @shortcut.level
      c 0x00
      d @shortcut.character_type
    when ShortcutType::ACTION..ShortcutType::BOOKMARK
      d @shortcut.id
      d @shortcut.character_type
    end
  end
end
