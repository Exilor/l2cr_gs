require "./abstract_variables"

class AccountVariables < AbstractVariables
  include Loggable

  private SELECT_QUERY = "SELECT * FROM account_gsdata WHERE account_name = ?"
  private DELETE_QUERY = "DELETE FROM account_gsdata WHERE account_name = ?"
  private INSERT_QUERY = "INSERT INTO account_gsdata (account_name, var, value) VALUES (?, ?, ?)"

  def initialize(account_name : String)
    super()
    @account_name = account_name
    restore_me
  end

  def restore_me : Bool
    GameDB.each(SELECT_QUERY, @account_name) do |rs|
      var = rs.get_string(:"var")
      val = rs.get_string(:"val")
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
      tr.exec(DELETE_QUERY, @account_name)
      each do |var, val|
        tr.exec(INSERT_QUERY, @account_name, var, val)
      end
    end

    true
  rescue e
    error e
    false
  ensure
    compare_and_set_changes(true, false)
  end
end
