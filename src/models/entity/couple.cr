class Couple
  include Loggable

  getter id = 0
  getter player1_id = 0
  getter player2_id = 0
  getter affiance_date = Calendar.new
  getter wedding_date = Calendar.new
  getter? married = false

  def initialize(couple_id : Int32)
    @id = couple_id

    sql = "SELECT * FROM mods_wedding WHERE id = ?"
    GameDB.each(sql, 1) do |rs|
      @player1_id = rs.get_i32("player1Id")
      @player2_id = rs.get_i32("player2Id")
      @married = rs.get_bool("married")

      @affiance_date.ms = rs.get_i64("affianceDate")
      @wedding_date.ms = rs.get_i64("weddingDate")
    end
  rescue e
    error e
  end

  def initialize(pc1 : L2PcInstance, pc2 : L2PcInstance)
    @player1_id = pc1.l2id
    @player2_id = pc2.l2id

    sql = "INSERT INTO mods_wedding (id, player1Id, player2Id, married, affianceDate, weddingDate) VALUES (?, ?, ?, ?, ?, ?)"
    GameDB.exec(
      sql,
      @player1_id,
      @player2_id,
      false,
      @affiance_date.ms,
      @wedding_date.ms
    )
    @id = IdFactory.next
  rescue e
    error e
  end

  def marry
    sql = "UPDATE mods_wedding set married = ?, weddingDate = ? where id = ?"
    @wedding_date.ms = Time.ms
    GameDB.exec(
      sql,
      true,
      @wedding_date.ms,
      @id
    )
    @married = true
  rescue e
    error e
  end

  def divorce
    sql = "DELETE FROM mods_wedding WHERE id=?"
    GameDB.exec(sql, @id)
  rescue e
    error e
  end
end
