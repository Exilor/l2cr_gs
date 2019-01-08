require "../interfaces/storable"
require "../interfaces/restorable"
require "../interfaces/script_type"

abstract class AbstractVariables < StatsSet
  # include Restorable
  # include Storable
  include Loggable
  include ScriptType

  def initialize
    super
    @has_changes = AtomicReference(Bool).new(false)
  end

  def []=(key : String, value)
    @has_changes.set(true)
    super
  end

  def has_changes?
    @has_changes.get
  end

  def delete(key : String)
    @has_changes.set(true)
    super
  end

  def compare_and_set_changes(expect : Bool, update : Bool) : Bool
    ret = @has_changes.get == expect
    @has_changes.set(update) if ret
    ret
  end
end
