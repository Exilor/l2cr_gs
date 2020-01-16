require "../interfaces/script_type"

abstract class AbstractVariables < StatsSet
  include Loggable
  include ScriptType

  private struct AtomicBool
    def initialize(value : Bool)
      @atomic = Atomic(UInt8).new(coerce(value))
    end

    def set(val : Bool)
      @atomic.set(coerce(val))
    end

    def get
      coerce(@atomic.get)
    end

    def lazy_set(val : Bool)
      @atomic.lazy_set(coerce(val))
    end

    def lazy_get
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

  def initialize
    super
    @has_changes = AtomicBool.new(false)
  end

  def []=(key : String, value : ValueType?)
    @has_changes.compare_and_set(false, true)
    super
  end

  def has_changes? : Bool
    @has_changes.get
  end

  def delete(key : String)
    @has_changes.compare_and_set(false, true)
    super
  end

  def compare_and_set_changes(expect : Bool, update : Bool) : Bool
    @has_changes.compare_and_set(expect, update)[1]
  end
end
