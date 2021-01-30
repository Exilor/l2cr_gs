module GameDB
  module CouplesDAOMySQLImpl
    extend self
    extend CouplesDAO

    private SELECT = "SELECT id FROM mods_wedding"
    private INSERT = "INSERT INTO mods_wedding (id, player1Id, player2Id, married, affianceDate, weddingDate) VALUES (?, ?, ?, ?, ?, ?)"
    private UPDATE = "UPDATE mods_wedding set married = ?, weddingDate = ? where id = ?"
    private DELETE = "DELETE FROM mods_wedding WHERE id=?"

    def load(& : Couple ->)
      GameDB.each(SELECT) do |rs|
        yield Couple.new(
          rs.get_i32(:"id"),
          rs.get_i32(:"player1Id"),
          rs.get_i32(:"player2Id"),
          rs.get_bool(:"married"),
          rs.get_i64(:"affianceDate"),
          rs.get_i64(:"weddingDate")
        )
      end
    rescue e
      error e
    end

    def insert(id : Int32, pc1_id : Int32, pc2_id : Int32, affiance_date : Int64, wedding_date : Int64)
      GameDB.exec(INSERT, id, pc1_id, pc2_id, false, affiance_date, wedding_date)
    rescue e
      error e
    end

    def update(wedding_date : Int64, couple_id : Int32)
      GameDB.exec(UPDATE, true, wedding_date, couple_id)
    rescue e
      error e
    end

    def delete(couple_id : Int32)
      GameDB.exec(DELETE, couple_id)
    rescue e
      error e
    end
  end
end
