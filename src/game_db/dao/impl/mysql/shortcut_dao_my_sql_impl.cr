module GameDB
  module ShortcutDAOMySQLImpl
    extend self
    extend ShortcutDAO

    private DELETE = "DELETE FROM character_shortcuts WHERE charId=? AND class_index=?"

    def delete(pc : L2PcInstance, class_index : Int32) : Bool
      GameDB.exec(DELETE, pc.l2id, class_index)
      true
    rescue e
      error e
      false
    end
  end
end
