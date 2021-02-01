module GameDB
  module TeleportBookmarkDAOMySQLImpl
    extend self
    extend TeleportBookmarkDAO

    private INSERT = "INSERT INTO character_tpbookmark (charId,Id,x,y,z,icon,tag,name) values (?,?,?,?,?,?,?,?)"
    private UPDATE = "UPDATE character_tpbookmark SET icon=?,tag=?,name=? where charId=? AND Id=?"
    private SELECT = "SELECT Id,x,y,z,icon,tag,name FROM character_tpbookmark WHERE charId=?"
    private DELETE = "DELETE FROM character_tpbookmark WHERE charId=? AND Id=?"

    def delete(pc : L2PcInstance, id : Int32)
      GameDB.exec(DELETE,pc.l2id, id)
    rescue e
      error e
    end

    def insert(pc : L2PcInstance, id : Int32, x : Int32, y : Int32, z : Int32, icon : Int32, tag : String, name : String)
      GameDB.exec(INSERT, pc.l2id, id, x, y, z, icon, tag, name)
    rescue e
      error e
    end

    def update(pc : L2PcInstance, id : Int32, icon : Int32, tag : String, name : String)
      GameDB.exec(UPDATE, icon, tag, name, pc.l2id,id)
    rescue e
      error e
    end

    def load(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id) do |rs|
        id = rs.get_i32(:"Id")
        x = rs.get_i32(:"x")
        y = rs.get_i32(:"y")
        z = rs.get_i32(:"z")
        icon = rs.get_i32(:"icon")
        tag = rs.get_string(:"tag")
        name = rs.get_string(:"name")

        pc.tp_bookmarks[id] = TeleportBookmark.new(id, x, y, z, icon, tag, name)
      end
    rescue e
      error e
    end
  end
end
