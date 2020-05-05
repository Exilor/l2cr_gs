require "./abstract_variables"

class PlayerVariables < AbstractVariables
  private SELECT_QUERY = "SELECT * FROM character_variables WHERE charId = ?"
  private DELETE_QUERY = "DELETE FROM character_variables WHERE charId = ?"
  private INSERT_QUERY = "INSERT INTO character_variables (charId, var, val) VALUES (?, ?, ?)"

  def initialize(l2id : Int32)
    super()
    @l2id = l2id
    restore_me
  end

  def restore_me : Bool
    GameDB.each(SELECT_QUERY, @l2id) do |rs|
      var = rs.get_string("var")
      val = rs.get_string("val")

      self[var] = val
    end

    true
  rescue e
    error e
    false
  ensure
    compare_and_set_changes(true, false)
  end

  def store_me : Bool
    return false unless has_changes?

    GameDB.transaction do |tr|
      tr.exec(DELETE_QUERY, @l2id)
      each do |var, val|
        tr.exec(INSERT_QUERY, @l2id, var, val)
      end
    end

    true
  rescue e
    error e
    false
  ensure
    compare_and_set_changes(true, false)
  end

  def player : L2PcInstance?
    L2World.get_player(@l2id)
  end
end
