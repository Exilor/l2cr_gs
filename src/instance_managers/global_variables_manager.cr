require "../models/variables/abstract_variables"

module GlobalVariablesManager
  extend self
  extend Loggable

  private class GlobalVariables < AbstractVariables
    private SELECT_QUERY = "SELECT * FROM global_variables"
    private DELETE_QUERY = "DELETE FROM global_variables"
    private INSERT_QUERY = "INSERT INTO global_variables (var, value) VALUES (?, ?)"

    def restore_me : Bool
      begin
        GameDB.each(SELECT_QUERY) do |rs|
          self[rs.get_string("var")] = rs.get_string("value")
        end
      rescue e
        error e
        return false
      ensure
        compare_and_set_changes(true, false)
      end

      true
    end

    def store_me : Bool
      unless has_changes?
        return false
      end

      begin
        GameDB.transaction do |tr|
          tr.exec(DELETE_QUERY)
          each { |key, value| tr.exec(INSERT_QUERY, key, value.to_s) }
        end
      rescue e
        error e
        return false
      ensure
        compare_and_set_changes(true, false)
      end

      true
    end
  end

  private INSTANCE = GlobalVariables.new

  def load
    debug "Loading..."
    restore_me
    info { "Loaded #{size} variables." }
  end

  {% for m in GlobalVariables.methods + AbstractVariables.methods + StatsSet.methods %}
    delegate {{m.name.stringify}}, to: INSTANCE
  {% end %}
end
