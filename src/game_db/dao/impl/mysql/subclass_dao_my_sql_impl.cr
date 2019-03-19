module GameDB
  module SubclassDAOMySQLImpl
    extend self
    extend SubclassDAO

    private SELECT = "SELECT class_id,exp,sp,level,class_index FROM character_subclasses WHERE charId=? ORDER BY class_index ASC"
    private INSERT = "INSERT INTO character_subclasses (charId,class_id,exp,sp,level,class_index) VALUES (?,?,?,?,?,?)"
    private UPDATE = "UPDATE character_subclasses SET exp=?,sp=?,level=?,class_id=? WHERE charId=? AND class_index =?"
    private DELETE = "DELETE FROM character_subclasses WHERE charId=? AND class_index=?"

    def update(pc : L2PcInstance)
      if pc.total_subclasses <= 0
        return
      end

      pc.subclasses.each_value do |sub|
        GameDB.exec(
          UPDATE,
          sub.exp,
          sub.sp,
          sub.level,
          sub.class_id,
          pc.l2id,
          sub.class_index
        )
      end
    rescue e
      error e
    end

    def insert(pc : L2PcInstance, new_class : Subclass) : Bool
      GameDB.exec(
        INSERT,
        pc.l2id,
        new_class.class_id,
        new_class.exp,
        new_class.sp,
        new_class.level,
        new_class.class_index
      )
      true
    rescue e
      error e
      false
    end

    def delete(pc : L2PcInstance, class_index : Int32)
      GameDB.exec(DELETE, pc.l2id, class_index)
    rescue e
      error e
    end

    def load(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id) do |rs|
        sub = Subclass.new(pc)
        sub.class_id = rs.get_i32("class_id")
        sub.exp = rs.get_i64("exp")
        sub.level = rs.get_i32("level")
        sub.sp = rs.get_i32("sp")
        sub.class_index = rs.get_i32("class_index")

        pc.subclasses[sub.class_index] = sub
      end
    end
  end
end
