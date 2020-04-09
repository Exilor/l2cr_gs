module IList(T)
  include Enumerable(T)
end


module IArray(T)
  include IList(T)
  include Indexable(T)

  struct Empty(T)
    include IArray(T)

    def unsafe_fetch(index : Int)
      raise IndexError.new
    end

    def size
      0
    end
  end

  def self.empty(type : T.class) : IArray(T) forall T
    Empty(T).new
  end
end

class Array(T)
  include IArray(T)
end


class Deque(T)
  include IArray(T)
end

module IHash(K, V)
  include Enumerable({K, V})

  struct Empty(K, V)
    include IHash(K, V)

    def each(& : {K, V} ->)
    end
  end

  def self.empty(k : K.class, v : V.class) : IHash(K, V) forall K, V
    Empty(K, V).new
  end
end

class Hash(K, V)
  include IHash(K, V)
end

module ISet(T)
  include Enumerable(T)

  struct Empty(T)
    include ISet(T)

    def each(& : T ->)
    end

    def <<(e : T)
      raise "Can't modify ISet::Empty"
    end

    def delete(e)
    end

    def empty?
      true
    end
  end

  def self.empty(type : T.class) : ISet(T) forall T
    Empty(T).new
  end
end

struct Set(T)
  include ISet(T)
end








require "./synchronizable"

module Concurrent
  abstract struct SynchronizedObject
    include Synchronizable

    private macro sync_delegate(*methods, to object)
      {% for method in methods %}
        {% if method.id.ends_with?('=') && method.id != "[]=" %}
          def {{method.id}}(arg)
            sync { {{object.id}}.{{method.id}} arg }
          end
        {% else %}
          def {{method.id}}(*args, **options)
            sync { {{object.id}}.{{method.id}}(*args, **options) }
          end

          {% if method.id != "[]=" %}
            def {{method.id}}(*args, **options)
              sync do
                {{object.id}}.{{method.id}}(*args, **options) do |*yield_args|
                  yield *yield_args
                end
              end
            end
          {% end %}
        {% end %}
      {% end %}
    end
  end

  struct Array(T) < SynchronizedObject
    include IArray(T)

    @array = [] of T

    def initialize(*args)
      @array = ::Array(T).new(*args)
    end

    delegate to_s, inspect, to: @array
    sync_delegate :[], :[]?, :[]=, empty?, find, clear, :<<, delete_at, push,
      delete_first, reject!, replace, concat, shift, shift?, pop, delete,
      to: @array

    {% for m in Indexable.methods %}
      sync_delegate "{{m.name}}", to: @array
    {% end %}

    def each
      sync { @array.each { |e| yield e } }
    end

    def safe_each
      sync { @array.safe_each { |e| yield e } }
    end

    def unsafe_fetch(index : Int)
      sync { @array.unsafe_fetch(index) }
    end
  end

  struct Deque(T) < SynchronizedObject
    include IArray(T)

    @deque = ::Deque(T).new

    delegate to_s, inspect, to: @deque
    sync_delegate :[], :[]?, :[]=, empty?, find, delete_first, :<<, shift,
      shift?, concat, clear, first, first?, delete, to: @deque

    {% for m in Indexable.methods %}
      sync_delegate "{{m.name}}", to: @deque
    {% end %}

    def each
      sync { @deque.each { |e| yield e } }
    end

    def safe_each
      sync { @deque.safe_each { |e| yield e } }
    end

    def unsafe_fetch(index : Int)
      sync { @deque.unsafe_fetch(index) }
    end
  end

  struct Map(K, V) < SynchronizedObject
    include IHash(K, V)

    @hash = {} of K => V

    delegate to_s, inspect, to: @hash
    sync_delegate each, :[], :[]?, :[]=, put_if_absent, empty?, has_key?, fetch,
      delete, each_value, each_key, values, keys, values_slice, keys_slice,
      local_each_value, find_value, clear, dig, dig?, to: @hash

    {% for m in Enumerable.methods %}
      sync_delegate "{{m.name}}", to: @hash
    {% end %}

    def each
      sync { @hash.each { |k, v| yield({k, v}) } }
    end

    def transform_values!
      sync { @hash.transform_values! { |v| yield(v) } }
    end
  end


  struct Set(T) < SynchronizedObject
    include ISet(T)

    @set = ::Set(T).new

    def initialize(initial_capacity : Int = 1)
      @set = ::Set(T).new(initial_capacity)
    end

    delegate to_s, inspect, to: @set
    sync_delegate empty?, delete, add, add?, clear, concat, subtract, :<<,
      to: @set

    {% for m in Enumerable.methods %}
      sync_delegate "{{m.name}}", to: @set
    {% end %}

    def each
      sync { @set.each { |e| yield e } }
    end
  end
end
