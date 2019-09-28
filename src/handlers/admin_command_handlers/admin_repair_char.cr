module AdminCommandHandler::AdminRepairChar
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    handle_repair(command)
    true
  end

  private def handle_repair(command)
    parts = command.split

    unless parts.size == 2
      return
    end

    player_name = parts[1]

    sql = "UPDATE characters SET x=-84318, y=244579, z=-3730 WHERE char_name=?"

    begin
      GameDB.exec(sql, player_name)
      l2id = CharNameTable.get_id_by_name(player_name)
      if l2id != 0
        sql = "DELETE FROM character_shortcuts WHERE charId=?"
        GameDB.exec(sql, l2id)
        sql = "UPDATE items SET loc=\"INVENTORY\" WHERE owner_id=?"
        GameDB.exec(sql, l2id)
      end
    rescue e
      error "Could not repair char."
      error e
    end
  end

  def commands
    {"admin_restore", "admin_repair"}
  end
end
