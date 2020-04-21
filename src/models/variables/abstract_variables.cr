require "../interfaces/script_type"

abstract class AbstractVariables
  include Loggable
  include ScriptType

  private struct AtomicBool
    def initialize(value : Bool)
      @atomic = Atomic(UInt8).new(coerce(value))
    end

    def set(val : Bool)
      @atomic.set(coerce(val))
    end

    def get : Bool
      coerce(@atomic.get)
    end

    def lazy_set(val : Bool)
      @atomic.lazy_set(coerce(val))
    end

    def lazy_get : Bool
      coerce(@atomic.lazy_get)
    end

    def compare_and_set(old, val)
      ret = @atomic.compare_and_set(coerce(old), coerce(val))
      {coerce(ret[0]), ret[1]}
    end

    private def coerce(value : Bool)
      value ? 1u8 : 0u8
    end

    private def coerce(value : Int)
      value == 1
    end
  end

  @stats_set = StatsSet.new
  @has_changes = AtomicBool.new(false)

  forward_missing_to @stats_set

  def []=(key : String, value)
    @has_changes.compare_and_set(false, true)
    @stats_set[key] = value
  end

  def has_changes? : Bool
    @has_changes.get
  end

  def delete(key : String)
    @has_changes.compare_and_set(false, true)
    @stats_set.delete(key)
  end

  def compare_and_set_changes(expect : Bool, update : Bool) : Bool
    @has_changes.compare_and_set(expect, update)[1]
  end
end
