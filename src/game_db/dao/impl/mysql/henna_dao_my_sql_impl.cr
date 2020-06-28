module GameDB
  module HennaDAOMySQLImpl
    extend self
    extend HennaDAO

    private SELECT = "SELECT slot,symbol_id FROM character_hennas WHERE charId=? AND class_index=?"
    private INSERT = "INSERT INTO character_hennas (charId,symbol_id,slot,class_index) VALUES (?,?,?,?)"
    private DELETE_ONE = "DELETE FROM character_hennas WHERE charId=? AND slot=? AND class_index=?"
    private DELETE_ALL = "DELETE FROM character_hennas WHERE charId=? AND class_index=?"

    def load(pc : L2PcInstance)
      henna = nil

      GameDB.each(SELECT, pc.l2id, pc.class_index) do |rs|
        slot = rs.get_i32(:"slot")
        next unless slot.between?(1, 3)
        symbol_id = rs.get_i32(:"symbol_id")
        next if symbol_id == 0
        henna ||= Slice(L2Henna?).new(3)
        henna[slot &- 1] = HennaData.get_henna(symbol_id)
      end

      if henna
        pc.henna = henna
      end
    rescue e
      error e
    end

    def insert(pc : L2PcInstance, henna : L2Henna, slot : Int32)
      GameDB.exec(INSERT, pc.l2id, henna.dye_id, slot, pc.class_index)
    rescue e
      error e
    end

    def delete(pc : L2PcInstance, slot : Int32)
      GameDB.exec(DELETE_ONE, pc.l2id, slot, pc.class_index)
    rescue e
      error e
    end

    def delete_all(pc : L2PcInstance, class_index : Int32)
      GameDB.exec(DELETE_ALL, pc.l2id, class_index)
    rescue e
      error e
    end
  end
end
