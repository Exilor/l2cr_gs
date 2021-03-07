require "./shortcut"

struct Shortcuts
  include Synchronizable
  include Loggable

  private MAX_SHORTCUTS_PER_BAR = 12

  @shortcuts = {} of Int32 => Shortcut

  initializer owner : L2PcInstance

  delegate size, to: @shortcuts

  def all_shortcuts : Enumerable(Shortcut)
    @shortcuts.local_each_value
  end

  def get_shortcut(slot : Int32, page : Int32) : Shortcut?
    @shortcuts[slot &+ (page &* MAX_SHORTCUTS_PER_BAR)]?
  end

  def register_shortcut(shortcut : Shortcut)
    sync do
      if shortcut.type.item?
        unless item = @owner.inventory.get_item_by_l2id(shortcut.id)
          debug "Item with Object ID #{shortcut.id} not found in #{@owner}'s inventory."
          return
        end
        shortcut.shared_reuse_group = item.shared_reuse_group
      end
      old = @shortcuts[shortcut.index]?
      @shortcuts[shortcut.index] = shortcut
      register_shortcut_in_db(shortcut, old)
    end
  end

  private def register_shortcut_in_db(shortcut : Shortcut, old : Shortcut?)
    if old
      delete_shortcut_from_db(old)
    end

    sql = "REPLACE INTO character_shortcuts (charId,slot,page,type,shortcut_id,level,class_index) values(?,?,?,?,?,?,?)"
    GameDB.exec(
      sql,
      @owner.l2id,
      shortcut.slot,
      shortcut.page,
      shortcut.type.to_i,
      shortcut.id,
      shortcut.level,
      @owner.class_index
    )
  rescue e
    error e
  end

  def delete_shortcut(slot : Int32, page : Int32)
    sync do
      old = @shortcuts.delete(slot &+ (page &* MAX_SHORTCUTS_PER_BAR))
      return unless old
      delete_shortcut_from_db(old)
      @owner.send_packet(Packets::Outgoing::ShortcutInit.new(@owner))
    end
  end

  def delete_shortcut_by_l2id(id : Int32)
    all_shortcuts.each do |shortcut|
      if shortcut.type.item? && shortcut.id == id
        delete_shortcut(shortcut.slot, shortcut.page)
        break
      end
    end
  end

  private def delete_shortcut_from_db(shortcut : Shortcut)
    sql = "DELETE FROM character_shortcuts WHERE charId=? AND slot=? AND page=? AND class_index=?"
    GameDB.exec(
      sql,
      @owner.l2id,
      shortcut.slot,
      shortcut.page,
      @owner.class_index
    )
  rescue e
    error e
  end

  def restore_me
    @shortcuts.clear

    sql = "SELECT charId, slot, page, type, shortcut_id, level FROM character_shortcuts WHERE charId=? AND class_index=?"
    GameDB.each(sql, @owner.l2id, @owner.class_index) do |rs|
      slot  = rs.get_i32(:"slot")
      page  = rs.get_i32(:"page")
      type  = rs.get_i32(:"type")
      id    = rs.get_i32(:"shortcut_id")
      level = rs.get_i32(:"level")

      shortcut = Shortcut.new(slot, page, ShortcutType[type], id, level, 1)
      @shortcuts[slot &+ (page &* MAX_SHORTCUTS_PER_BAR)] = shortcut
    end
  rescue e
    error e
  end

  def update_shortcuts(skill_id : Int32, skill_level : Int32)
    all_shortcuts.each do |shc|
      if shc.id == skill_id && shc.type.skill?
        sc = Shortcut.new(shc.slot, shc.page, shc.type, shc.id, skill_level, 1)

        @owner.send_packet(Packets::Outgoing::ShortcutRegister.new(sc))
        @owner.register_shortcut(sc)
      end
    end
  end
end
