class Packets::Outgoing::ShortcutInit < GameServerPacket
  @shortcuts : Shortcuts

  def initialize(pc : L2PcInstance)
    @shortcuts = pc.shortcuts
  end

  private def write_impl
    c 0x45

    d @shortcuts.size
    @shortcuts.all_shortcuts.each do |sc|
      d sc.type.to_i
      d sc.slot + (sc.page * 12)
      case sc.type
      when .item? # ShortcutType::ITEM
        d sc.id
        d 0x01
        d sc.shared_reuse_group
        d 0x00
        d 0x00
        h 0x00
        h 0x00
      when .skill? # ShortcutType::SKILL
        d sc.id
        d sc.level
        c 0x00
        d 0x01
      else
        d sc.id
        d 0x01
      end
    end
  end
end
